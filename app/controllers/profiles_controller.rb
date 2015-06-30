class ProfilesController < ResourceController
  RESOURCE_ACTIONS = %i(show edit update destroy)

  before_filter :fetch_profile, only: RESOURCE_ACTIONS
  before_filter :authorize_generic, except: RESOURCE_ACTIONS

  respond_to :html
  respond_to :json, only: :show

  def index
    skip_policy_scope
    @profile_categories = LoadProfileCategory.where(parent_id: nil)
  end

  # GET /profiles
  def show
    respond_with(@profile)
  end

  # GET /profiles/new
  def new
  end

  # POST /profiles
  def create
    @profile = current_user.profiles.create(profile_params)
    respond_with(@profile)
  end

  # GET /profiles/:id/edit
  def edit
  end

  # PATCH /profiles/:id
  def update
    @profile.update_attributes(profile_params)
    respond_with(@profile)
  end

  # DELETE /profiles/:id
  def destroy
    @profile.destroy
    redirect_to(profiles_url)
  end

  #######
  private
  #######

  def fetch_profile
    raise NotImplementedError, "Any sub-class of ProfilesController must implement fetch_profile"
  end

  def profile_scope
    raise NotImplementedError, "Any sub-class of ProfilesController must implement profile_scope"
  end

  def profile_params
    params.require(profile_scope).permit(
      :key, :name, :curve, :public, :profile_category_id,
      { technology_profiles_attributes: [:id, :technology, :_destroy] }
    )
  end
end
