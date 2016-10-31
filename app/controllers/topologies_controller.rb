class TopologiesController < ResourceController
  RESOURCE_ACTIONS = %i(show update)

  respond_to :html
  respond_to :js, only: :update
  respond_to :json, only: :show

  before_filter :fetch_topology, only: RESOURCE_ACTIONS
  before_filter :authorize_generic, except: RESOURCE_ACTIONS

  skip_before_filter :authenticate_user!, only: :show

  # GET /topologies
  def show
    respond_with(@topology)
  end

  # PATCH /topologies/:id
  def update
    @topology.update_attributes(topology_params)

    if @topology.testing_ground.business_case
      @topology.testing_ground.business_case.clear_job!
    end

    respond_with(@topology)
  end

  private

  def fetch_topology
    @topology = Topology.find(params[:id])
    authorize @topology
  end

  def topology_params
    params.require(:topology).permit(:graph)
  end
end
