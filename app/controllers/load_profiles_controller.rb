class LoadProfilesController < ResourceController
  RESOURCE_ACTIONS = %i(show edit update destroy)

  before_filter :fetch_load_profile, only: RESOURCE_ACTIONS
  before_filter :authorize_generic, except: RESOURCE_ACTIONS

  respond_to :html
  respond_to :json, only: :show

  def index
    skip_policy_scope
    @load_profile_categories = LoadProfileCategory.where(parent_id: nil)
  end

  # GET /load_profiles
  def show
  end

  # GET /load_profiles/new
  def new
    @load_profile = LoadProfile.new
  end

  # POST /load_profiles
  def create
    @load_profile = current_user.load_profiles.create(load_profile_params)
    respond_with(@load_profile)
  end

  # GET /load_profiles/:id/edit
  def edit
  end

  # PATCH /load_profiles/:id
  def update
    @load_profile.update_attributes(load_profile_params)
    respond_with(@load_profile)
  end

  # DELETE /load_profiles/:id
  def destroy
    @load_profile.destroy
    redirect_to(load_profiles_url)
  end

  #######
  private
  #######

  def fetch_load_profile
    @load_profile = LoadProfile.find(params[:id])
    authorize @load_profile
  end

  def load_profile_params
    params.require(:load_profile).permit(
      :key, :name, :curve, :load_profile_category_id,
      { technology_profiles_attributes: [:id, :technology, :_destroy] }
    )
  end
end
