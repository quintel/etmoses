class TestingGroundsController < ApplicationController
  respond_to :html, :json
  respond_to :csv, only: :technologies

  # GET /topologies
  def index
    respond_with(@testing_grounds = TestingGround.all.order('created_at DESC'))
  end

  # GET /topologies/new
  def new
    respond_with(@testing_ground = TestingGround.new(topology: Topology.new))
  end

  # GET /topologies/import
  def import
    respond_with(@import = Import.new)
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

  # POST /topologies
  def create
    respond_with(@testing_ground = TestingGround.create(testing_ground_params))
  end

  # GET /topologies/:id
  def show
    respond_with(@testing_ground = TestingGround.find(params[:id]))
  rescue StandardError => ex
    if request.format.json?
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

  private

  # Internal: Returns the permitted parameters for creating a testing ground.
  def testing_ground_params
    tg_params = params
      .require(:testing_ground)
      .permit([:name, :technologies, :technologies_csv, :scenario_id,
               { topology_attributes: :graph }])

    if tg_params[:technologies_csv]
      tg_params.delete(:technologies)
    else
      yamlize_attribute!(tg_params, :technologies)
    end

    yamlize_attribute!(tg_params[:topology_attributes], :graph)

    tg_params
  end

  # Internal: Given a hash and an attribute key, assumes the value is a YAML
  # string and converts it to a Ruby hash.
  def yamlize_attribute!(hash, attr)
    hash[attr] = YAML.load(hash[attr]) if hash[attr]
  end
end # TestingGroundsController
