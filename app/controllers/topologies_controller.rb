class TopologiesController < ApplicationController
  respond_to :html
  respond_to :json, only: :show

  before_filter :fetch_topology, except: [:index, :new, :create]

  def index
    @topologies = Topology.overview(current_user)
  end

  # GET /topologies
  def show
    PrivatePolicy.new(self, @topology).authorize
  end

  # GET /topologies/new
  def new
    @topology = Topology.new
  end

  # POST /topologies
  def create
    respond_with(@topology = current_user.topologies.create(topology_params))
  end

  # GET /topologies/:id/edit
  def edit
    PrivatePolicy.new(self, @topology).authorize
  end

  # PATCH /topologies/:id
  def update
    if PrivatePolicy.new(self, @topology).authorized?
      @topology.update_attributes(topology_params)

      respond_with(@topology)
    else
      redirect_to topologies_path
    end
  end

  # DELETE /topologies/:id
  def destroy
    if PrivatePolicy.new(self, @topology).authorize
      @topology.destroy
      redirect_to(topologies_url)
    else
      redirect_to topologies_path
    end
  end

  private

    def fetch_topology
      @topology = Topology.find(params[:id])
    end

    def topology_params
      params.require(:topology).permit(:name, :graph, :permissions)
    end
end
