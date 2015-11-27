class TopologiesController < ResourceController
  RESOURCE_ACTIONS = %i(show edit update destroy clone download_as_png)

  respond_to :html
  respond_to :js, only: :clone
  respond_to :json, only: :show
  respond_to :png, only: :download_as_png

  before_filter :fetch_topology, only: RESOURCE_ACTIONS
  before_filter :authorize_generic, except: RESOURCE_ACTIONS
  before_filter :fetch_testing_ground, only: :clone

  skip_before_filter :authenticate_user!, only: [:show, :index]
  skip_before_filter :verify_authenticity_token, only: [:download_as_png]

  def index
    @topologies = policy_scope(Topology.named).in_name_order
  end

  # GET /topologies
  def show
    respond_with(@topology)
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
  end

  # PATCH /topologies/:id
  def update
    @topology.update_attributes(topology_params)
    respond_with(@topology)
  end

  # POST /topologies/:id/clone
  def clone
    cloner = TestingGround::Cloner.new(@testing_ground, @topology, topology_params)
    cloner.clone

    @errors = cloner.errors
  end

  # DELETE /topologies/:id
  def destroy
    if TestingGround.where(topology: @topology).count > 0
      @topology.update_attribute(:user, User.orphan)
    else
      @topology.destroy
    end

    redirect_to(topologies_url)
  end

  # POST /topologies/:id/download_as_png.png
  def download_as_png
    img = Magick::Image.from_blob(params[:svg]) do
      self.format = 'SVG'
      self.background_color = 'transparent'
      self.quality = 100
    end

    send_data(
      img[0].to_blob do
        self.format = 'PNG'
        self.quality = 100
      end,
      filename: "#{ @topology.filename }.png",
      content_type: 'image/png')
  end

  private

  def fetch_topology
    @topology = Topology.find(params[:id])
    authorize @topology
  end

  def topology_params
    params.require(:topology).permit(:name, :user_id, :graph, :public)
  end
end
