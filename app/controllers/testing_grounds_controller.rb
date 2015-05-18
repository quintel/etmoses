class TestingGroundsController < ApplicationController
  respond_to :html, :json
  respond_to :csv, only: :technologies
  respond_to :js, only: :calculate_concurrency

  before_filter :prepare_export, only: %i( export perform_export )

  # GET /topologies
  def index
    respond_with(@testing_grounds = TestingGround.all.order('created_at DESC'))
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
    respond_with(@testing_ground = TestingGround.create(testing_ground_params))
  end

  # GET /topologies/:id
  def show
    @testing_ground = TestingGround.find(params[:id])

    respond_to do |format|
      format.html
      format.json do
        render json: @testing_ground.to_json(storage: params[:storage] == '1')
      end
    end
  rescue StandardError => ex
    if request.format.json?
      notify_airbrake(ex) if defined?(Airbrake)

      result = { error: 'Sorry, your testing ground could not be calculated' }

      if Rails.env.development? || Rails.env.test?
        result[:message]   = "#{ ex.class }: #{ ex.message }"
        result[:backtrace] = ex.backtrace
      end

      render json: result, status: 500
    else
      raise ex
    end
  end

  # GET /testing_grounds/:id/technologies.csv
  def technologies
    respond_with(TestingGround.find(params[:id]).technologies)
  end

  # GET /topologies/:id/edit
  def edit
    respond_with(@testing_ground = TestingGround.find(params[:id]))
  end

  # PATCH /topologies/:id
  def update
    @testing_ground = TestingGround.find(params[:id])
    @testing_ground.update_attributes(testing_ground_params)

    respond_with(@testing_ground)
  end

  # POST /topologies/calculate_concurrency
  def calculate_concurrency
    calculated_concurrency = TestingGround::ConcurrencyCalculator.new(
                                params[:profile],
                                params[:topology],
                                params[:profile_differentiation]).calculate

    @testing_ground_profile = TechnologyList.from_hash(calculated_concurrency)
  end

  private

  # Internal: Returns the permitted parameters for creating a testing ground.
  def testing_ground_params
    tg_params = params
      .require(:testing_ground)
      .permit([:name, :technologies, :technology_profile, :technologies_csv,
               :scenario_id, :topology_id])

    if tg_params[:technologies_csv]
      tg_params.delete(:technologies)
    else
      yamlize_attribute!(tg_params, :technologies)
    end

    yamlize_attribute!(tg_params, :technology_profile)

    # Some attributes which should be considered "not present" are submitted by
    # the technology table as an empty string. Delete them.
    tg_params[:technology_profile].each do |_, techs|
      techs.each do |tech|
        tech.delete_if { |_attr, value| value.blank? }
      end
    end

    tg_params
  end

  # Internal: Given a hash and an attribute key, assumes the value is a YAML
  # string and converts it to a Ruby hash.
  def yamlize_attribute!(hash, attr)
    hash[attr] = YAML.load(hash[attr]) if hash[attr]
  end

  # Internal: Before filter which loads models required for export-to-ETEngine
  # eactions.
  def prepare_export
    @testing_ground = TestingGround.find(params[:id])
    @export         = Export.new(@testing_ground)
  end
end # TestingGroundsController
