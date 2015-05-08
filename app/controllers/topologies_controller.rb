class TopologiesController < ApplicationController
  respond_to :html
  respond_to :json, only: :show

  before_filter :fetch_topology, except: [:index, :new, :create]

  def index
    @topologies = Topology.all
  end

  # GET /topologies
  def show
    respond_with(@topology = Topology.find(params[:id]))
  end

  # GET /topologies/new
  def new
    @topology = Topology.new
  end

  # POST /topologies
  def create
    respond_with(@topology = Topology.create(topology_params))
  end

  # GET /topologies/:id/edit
  def edit
    # @topology = Topology.find(params[:id])
  end

  # PATCH /topologies/:id
  def update
    # @topology = Topology.find(params[:id])
    @topology.update_attributes(topology_params)

    respond_with(@topology)
  end

  # DELETE /topologies/:id
  def destroy
    @topology.destroy
    redirect_to(topologies_url)
  end

  private

    def fetch_topology
      @topology = Topology.find(params[:id])
    end

    def topology_params
      params.require(:topology).permit(:name, :graph)
    end
end
