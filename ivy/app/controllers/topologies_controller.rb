class TopologiesController < ApplicationController
  respond_to :html, :json
  respond_to :png, only: :show

  rescue_from Refinery::IncalculableGraphError do |ex|
    result = { error: 'Sorry, your topology could not be calculated' }

    if Rails.env.development? || Rails.env.test?
      result[:message]   = ex.message
      result[:backtrace] = ex.backtrace
    end

    render json: result, status: 500
  end

  # GET /topologies
  def index
    respond_with(@topologies = Topology.all.order('created_at DESC'))
  end

  # GET /topologies/new
  def new
    respond_with(@topology = Topology.new)
  end

  # GET /topologies/import
  def import
    respond_with(@import = Import.new)
  end

  # POST /topologies/import
  def perform_import
    @import = Import.new(params[:import])

    if @import.valid?
      @topology = @import.topology
      render :new
    else
      render :import
    end
  end

  # POST /topologies
  def create
    respond_with(@topology = Topology.create(topology_params))
  end

  # GET /topologies/:id
  def show
    @topology = Topology.find(params[:id])

    respond_with(@topology) do |format|
      format.png do
        graph   = @topology.calculator.calculate
        diagram = Refinery::Diagram::Base.new(graph)

        render text: diagram.draw_to(String),
          type: 'image/png', disposition: 'inline'
      end
    end
  end

  # GET /topologies/:id/edit
  def edit
    respond_with(@topology = Topology.find(params[:id]))
  end

  # PATCH /topologies/:id
  def update
    @topology = Topology.find(params[:id])
    @topology.update_attributes(topology_params)

    respond_with(@topology)
  end

  private

  # Internal: Returns the permitted parameters for creating a topology.
  def topology_params
    topology = params[:topology] || {}

    [ :graph, :technologies ].each_with_object({}) do |key, data|
      data[key] = YAML.load(topology[key]) if topology[key]
    end
  end
end # TopologiesController
