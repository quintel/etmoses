class LoadProfilesController < ResourceController
  RESOURCE_ACTIONS = %i(show edit update destroy)

  before_filter :fetch_profile, only: RESOURCE_ACTIONS
  before_filter :authorize_generic, except: RESOURCE_ACTIONS
  before_filter :fetch_technologies, only: %i(new create edit update)

  respond_to :html

  def index
    skip_policy_scope
    @load_profile_categories = LoadProfileCategory.where(parent_id: nil)
  end

  # GET /load_profiles
  def show
    respond_with(@profile)
  end

  # GET /load_profiles/new
  def new
    @profile = LoadProfile.new
    2.times{ @profile.profile_curves.build }
  end

  def edit
    (2 - @profile.profile_curves.count).times do
      @profile.profile_curves.build
    end
    super
  end

  def create
    @profile = current_user.load_profiles.create(profile_params)
    super
  end

  #######
  private
  #######

  def profile_scope
    :load_profile
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
      { profile_curves_attributes: [:id, :curve, :curve_type]}
    )
  end
end
