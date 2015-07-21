class TestingGroundsController < ResourceController
  RESOURCE_ACTIONS = %i(edit update show technology_profile data destroy save_as finance)

  respond_to :html, :json
  respond_to :csv, only: :technology_profile
  respond_to :js, only: :calculate_concurrency

  before_filter :find_testing_ground, only: RESOURCE_ACTIONS
  before_filter :authorize_generic, except: RESOURCE_ACTIONS

  before_filter :prepare_export, only: %i(export perform_export)

  before_filter :load_technologies, only: [:perform_import, :update, :create,
                                           :edit, :new, :calculate_concurrency]

  skip_before_filter :verify_authenticity_token, only: [:data]

  # GET /topologies
  def index
    @testing_grounds = policy_scope(TestingGround).latest_first
  end

  # GET /topologies/import
  def import
    @import = Import.new(params.slice(:scenario_id))
  end

  # POST /topologies/import
  def perform_import
    @import = Import.new(params[:import])

    if @import.valid?
      @testing_ground = @import.testing_ground
      render :new
    else
      render :import
    end
  end

  # GET /testing_grounds/:id/export
  def export
  end

  # POST /testing_grounds/:id/export
  def perform_export
    redirect_to("http://beta.pro.et-model.com/scenarios/" +
                "#{ @export.export['id'] }")
  end

  # GET /topologies/new
  def new
    respond_with(@testing_ground = TestingGround.new)
  end

  # POST /topologies
  def create
    respond_with(@testing_ground = current_user.testing_grounds
                                     .create(testing_ground_params))
  end

  # GET /topologies/:id
  def show
  end

  # POST /testing_grounds/:id/data
  def data
    begin
      render json: @testing_ground.to_json(params[:strategies])
    rescue StandardError => ex
      notify_airbrake(ex) if defined?(Airbrake)

      result = if ex.class == TestingGround::DataError
                 { error: ex.message }
               else
                 { error: I18n.t("testing_grounds.error.data") }
               end


      if Rails.env.development? || Rails.env.test?
        result[:message]   = "#{ ex.class }: #{ ex.message }"
        result[:backtrace] = ex.backtrace

        Rails.logger.debug(ex.message)
        Rails.logger.debug(ex.backtrace.join("\n"))
      end

      render json: result, status: 500
    end
  end

  # GET /topologies/:id/edit
  def edit
  end

  # PATCH /topologies/:id
  def update
    @testing_ground.update_attributes(testing_ground_params)
    respond_with(@testing_ground)
  end

  # POST /topologies/calculate_concurrency
  def calculate_concurrency
    concurrency = TestingGround::TechnologyProfileScheme.new(
                    JSON.parse(params[:technology_distribution])
                  ).build

    @testing_ground_profile = TechnologyList.from_hash(concurrency)
  end

  # GET /testing_grounds/:id/technology_profile.csv
  def technology_profile
    respond_with(@testing_ground.technology_profile)
  end

  def save_as
    testing_ground = @testing_ground.dup
    testing_ground.save

    redirect_to(testing_ground)
  end

  def finance
    @business_case = Finance::BusinessCaseCalculator.new(@testing_ground)
  end

  private

  # Internal: Returns the permitted parameters for creating a testing ground.
  def testing_ground_params
    tg_params = params
      .require(:testing_ground)
      .permit([:name, :technology_profile, :public,
               :technology_profile_csv, :scenario_id, :topology_id])

    if tg_params[:technology_profile_csv]
      tg_params.delete(:technology_profile)
    elsif tg_params[:technology_profile]
      yamlize_attribute!(tg_params, :technology_profile)

      # Some attributes which should be considered "not present" are submitted by
      # the technology table as an empty string. Delete them.
      tg_params[:technology_profile].each do |_, techs|
        techs.each do |tech|
          tech.delete_if { |_attr, value| value.blank? }
        end
      end
    end

    tg_params
  end

  # Internal: Given a hash and an attribute key, assumes the value is a YAML
  # string and converts it to a Ruby hash.
  def yamlize_attribute!(hash, attr)
    hash[attr] = YAML.load(hash[attr]) if hash[attr]
  end

  def find_testing_ground
    @testing_ground = TestingGround.find(params[:id])
    authorize @testing_ground
  end

  # Internal: Before filter which loads models required for export-to-ETEngine
  # eactions.
  def prepare_export
    @testing_ground = TestingGround.find(params[:id])
    @export         = Export.new(@testing_ground)
  end

  def load_technologies
    @technologies = Technology.all
  end
end # TestingGroundsController
