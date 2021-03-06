class TestingGroundsController < ResourceController
  RESOURCE_ACTIONS = %i(edit update show technology_profile data destroy save_as
                        update_strategies gas_load heat_load clone)

  respond_to :html, :json
  respond_to :csv, only: :technology_profile
  respond_to :js, only: [:update, :render_template]

  before_filter :find_testing_ground, only: RESOURCE_ACTIONS
  before_filter :authorize_generic, except: RESOURCE_ACTIONS

  before_filter :prepare_export, only: %i(export perform_export)

  before_filter :load_technologies_and_profiles, only: [
    :perform_import, :update, :create, :edit, :new,
    :render_template
  ]

  skip_before_filter :verify_authenticity_token, only: [:data, :save_as]
  skip_before_filter :authenticate_user!, only: [
    :show, :data, :index, :gas_load, :heat_load
  ]

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
      @technology_distribution = @testing_ground.technology_profile
                                 .each_tech.map(&:attributes)
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
    redirect_to("#{ Settings.etmodel_host }/scenarios/" +
                "#{ @export.export['id'] }")
  end

  # GET /testing_grounds/new
  def new
    respond_with(@testing_ground = TestingGround.new)
  end

  # POST /testing_grounds
  def create
    @testing_ground = current_user.testing_grounds.create(testing_ground_params)

    respond_with(TestingGround::Creator.new(@testing_ground).create)
  end

  # GET /testing_grounds/:id
  def show
  end

  # GET /testing_grounds/:id/gas_load
  def gas_load
  end

  # GET /testing_grounds/:id/heat_load
  def heat_load
  end

  # POST /testing_grounds/:id/data
  def data
    begin
      render json: TestingGround::Calculator.new(
        @testing_ground, params[:calculation] || {}).calculate
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

  # POST /testing_grounds/:id/update_strategies
  def update_strategies
    if TestingGround::StrategyUpdater.new(@testing_ground, params).update
      @testing_ground.business_case.clear_job!

      render json: { status: 'ok' }
    end
  end

  # GET /testing_grounds/:id/edit
  def edit
    @technology_distribution = @testing_ground.technology_profile
                               .each_tech.map(&:attributes)

    if @testing_ground.heat_source_list
      @heat_source_list = HeatSourceListDecorator.new(
        @testing_ground.heat_source_list).decorate
    end

    if @testing_ground.heat_asset_list
      @heat_asset_list = HeatAssetListDecorator.new(
        @testing_ground.heat_asset_list).decorate
    end

    if @testing_ground.gas_asset_list
      @gas_asset_list = GasAssetListDecorator.new(
        @testing_ground.gas_asset_list).decorate
    end

    @heat_connections =
      Market::Measures::NumberOfHeatConnections.count_with_technology_profile(
        @testing_ground.technology_profile
      )
  end

  # PATCH /testing_grounds/:id
  def update
    @form_type = params[:testing_ground][:form_type]

    if @testing_ground.update_attributes(testing_ground_params)
      @testing_ground.business_case && @testing_ground.business_case.clear_job!
    end

    respond_with(@testing_ground)
  end

  def render_template
    @scope      = params[:scope]
    @technology = TestingGround::TechnologyBuilder.new(
      params.slice(:key, :scenario_id, :buffer).merge(
        load_profiles: @load_profiles[params[:key]]
      )
    ).build
  end

  # GET /testing_grounds/:id/technology_profile.csv
  def technology_profile
    respond_with(@testing_ground.technology_profile)
  end

  def save_as
    begin
      @testing_ground = TestingGround::SaveAs.run(
        @testing_ground, testing_ground_params[:name], current_user
      )

      render json: { redirect: testing_ground_path(@testing_ground) }
    rescue ActiveRecord::RecordInvalid => ex
      render json: { errors: ex.record.errors }, status: 422
    end
  end

  # DELETE /testing_grounds/:id
  def destroy
    @testing_ground.destroy

    flash[:notice] = "You succesfully removed #{ @testing_ground.name }"
    redirect_to root_path
  end

  private

  # Internal: Returns the permitted parameters for creating a testing ground.
  def testing_ground_params
    tg_params = params
      .require(:testing_ground)
      .permit(:name, :technology_profile, :public, :behavior_profile_id,
               :parent_scenario_id, :technology_profile_csv, :scenario_id,
               :central_heat_buffer_capacity,
               market_model_attributes: [:interactions, :market_model_template_id],
               topology_attributes: [:graph, :topology_template_id])

    if tg_params[:technology_profile_csv]
      tg_params.delete(:technology_profile)
    elsif tg_params[:technology_profile]
      yamlize_attribute!(tg_params, :technology_profile)
    end

    tg_params
  end

  def strategy_params
    params.require(:strategies).permit(
      :battery_storage,
      :ev_capacity_constrained,
      :ev_excess_constrained,
      :ev_storage,
      :solar_power_to_heat,
      :solar_power_to_gas,
      :hp_capacity_constrained,
      :hhp_switch_to_gas,
      :postponing_base_load,
      :saving_base_load,
      :capping_solar_pv,
      :capping_fraction
    )
  end

  # Internal: Given a hash and an attribute key, assumes the value is a YAML
  # string and converts it to a Ruby hash.
  def yamlize_attribute!(hash, attr)
    hash[attr] = YAML.load(hash[attr]) if hash[attr]
  end

  def find_testing_ground
    @testing_ground = TestingGround.find(params[:id])
    session[:testing_ground_id] = params[:id]
    authorize @testing_ground
  end

  # Internal: Before filter which loads models required for export-to-ETEngine
  # eactions.
  def prepare_export
    @testing_ground = TestingGround.find(params[:id])
    @export         = Export.new(@testing_ground)
  end

  def load_technologies_and_profiles
    @technologies  = Technology.where(visible: true) - Technology.heat_sources_for_table
    @stakeholders  = Stakeholder.all

    @load_profiles = LoadProfile
      .joins(:technology_profiles)
      .select("`technology_profiles`.`technology`, `load_profiles`.*")
      .ordered_by_name
      .group_by {|t| t.technology }
  end
end # TestingGroundsController
