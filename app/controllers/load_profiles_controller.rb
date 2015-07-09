class LoadProfilesController < ProfilesController
  before_filter :fetch_technologies, only: %i(new create edit update)

  respond_to :html
  respond_to :json, only: :show

  def index
    skip_policy_scope
    @load_profile_categories = LoadProfileCategory.where(parent_id: nil)
  end

  # GET /load_profiles/new
  def new
    @profile = LoadProfile.new
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

  def load_profile_params
    params.require(:load_profile).permit(
      :key, :name, :curve, :public, :load_profile_category_id,
      { technology_profiles_attributes: [:id, :technology, :_destroy] }
    )
  end
end
