class LoadProfilesController < ResourceController
  RESOURCE_ACTIONS = %i(show edit update destroy)

  before_filter :fetch_profile, only: RESOURCE_ACTIONS
  before_filter :authorize_generic, except: RESOURCE_ACTIONS
  before_filter :fetch_technologies, only: %i(new create edit update)

  respond_to :html
  respond_to :json, only: :show

  skip_before_filter :authenticate_user!, only: [:index, :show]

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
      unless @profile.load_profile_components.map(&:curve_type).include?(curve_type)
        @profile.load_profile_components.build(curve_type: curve_type)
      end
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
    permitted_attributes(@profile || LoadProfile.new)
  end
end
