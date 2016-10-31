class TopologyTemplatesController < ResourceController
  RESOURCE_ACTIONS = %i(show edit update destroy download_as_png)

  respond_to :html
  respond_to :js, only: :clone
  respond_to :json, only: :show
  respond_to :png, only: :download_as_png

  before_filter :fetch_topology, only: RESOURCE_ACTIONS
  before_filter :authorize_generic, except: RESOURCE_ACTIONS

  skip_before_filter :authenticate_user!, only: [:show, :index]
  skip_before_filter :verify_authenticity_token, only: [:download_as_png]

  def index
    @topology_templates = policy_scope(TopologyTemplate)
  end

  def new
    @topology_template = TopologyTemplate.new
  end

  def create
    respond_with(@topology_template =
      current_user.topology_templates.create(topology_template_params))
  end

  def show
    respond_with(@topology_template)
  end

  def edit
  end

  def update
    if @topology_template.update_attributes(topology_template_params)
      redirect_to topology_template_path(@topology_template)
    else
      render :edit
    end
  end

  def destroy
    @topology_template.destroy
    redirect_to topology_templates_path
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
      filename: "#{ @topology_template.filename }.png",
      content_type: 'image/png')
  end

  private

  def topology_template_params
    params.require(:topology_template)
      .permit(policy(:topology_template).permitted_attributes)
  end

  def fetch_topology
    @topology_template = TopologyTemplate.find(params[:id])
    authorize @topology_template
  end
end
