class ProfilesController < ResourceController
  RESOURCE_ACTIONS = %i(show edit update destroy)

  before_filter :fetch_profile, only: RESOURCE_ACTIONS
  before_filter :authorize_generic, except: RESOURCE_ACTIONS

  skip_before_filter :authenticate_user!, only: %i(show index)

  respond_to :html
  respond_to :json, only: :show

  def index
    skip_policy_scope
    @load_profile_categories = LoadProfileCategory.where(parent_id: nil)
    @price_curves            = PriceCurve.all
    @temperature_profiles    = TemperatureProfile.all
  end

  def new
    @profile = Profile.new
  end

  def create
    @profile = current_user.profiles.new(profile_params)

    if @profile.save
      redirect_to profile_path(@profile)
    else
      render :new
    end
  end

  def show
    respond_with(@profile)
  end

  def edit
  end

  def update
    if @profile.update_attributes(profile_params)
      redirect_to profile_path(@profile)
    else
      render :edit
    end
  end

  def destroy
    @profile.destroy

    redirect_to(profiles_path)
  end

  private

  def authorize_generic
    authorize Profile
  end

  def fetch_profile
    @profile = Profile.find(params[:id])
    authorize @profile
  end

  def profile_params
    params.require(:profile).permit(:key, :type, :name, :curve, :public)
  end
end
