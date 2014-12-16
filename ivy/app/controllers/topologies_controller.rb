class TopologiesController < ApplicationController
  respond_to :html, :json

  # GET /topologies
  def index
    respond_with(@topologies = Topology.all.order('created_at DESC'))
  end

  # GET /topologies/new
  def new
    respond_with(@topology = Topology.new)
  end

  # POST /topologies
  def create
    respond_with(Topology.create(topology_params))
  end

  # GET /topologies/:id
  def show
    respond_with(@topology = Topology.find(params[:id]))
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
