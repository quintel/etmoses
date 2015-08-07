class LoadProfilesController < ResourceController
  RESOURCE_ACTIONS = %i(show edit update destroy)

  before_filter :fetch_profile, only: RESOURCE_ACTIONS
  before_filter :authorize_generic, except: RESOURCE_ACTIONS
  before_filter :fetch_technologies, only: %i(new create edit update)

  respond_to :html
  respond_to :json, only: :show

  def index
    skip_policy_scope
    @load_profile_categories = LoadProfileCategory.where(parent_id: nil)
    @price_curves = PriceCurve.all
  end

  # GET /load_profiles
  def show
    respond_with(@profile)
  end

  # GET /load_profiles/new
  def new
    @profile = LoadProfile.new
    build_load_profile_components
  end

  def edit
    build_load_profile_components
  end

  def update
    @profile.update_attributes(profile_params)
    respond_with(@profile)
  end

  def create
    @profile = current_user.load_profiles.create(profile_params)
    respond_with(@profile)
  end

  # DELETE /profiles/:id
  def destroy
    @profile.destroy
    redirect_to(load_profiles_url)
  end

  private

  def build_load_profile_components
    LoadProfileComponent::CURVE_TYPES.values.flatten.each do |curve_type|
      @profile.load_profile_components.build(curve_type: curve_type)
    end
  end

  def fetch_profile
    @profile = LoadProfile.find(params[:id])
    authorize @profile
  end

  def fetch_technologies
    @technologies = Technology.all
  end

  def profile_params
    params.require(:load_profile).permit(
      :key, :name, :public, :load_profile_category_id,
      { technology_profiles_attributes: [:id, :technology, :_destroy] },
      { load_profile_components_attributes: [:id, :curve, :curve_type]}
    )
  end
end
