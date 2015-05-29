class LoadProfilesController < ApplicationController
  respond_to :html
  respond_to :json, only: :show

  before_filter :fetch_load_profile, except: [:index, :new, :create]

  def index
    @load_profile_categories = LoadProfileCategory.where(parent_id: nil)
  end

  # GET /load_profiles
  def show
    PrivatePolicy.new(self, @load_profile).authorize
  end

  # GET /load_profiles/new
  def new
    @load_profile = LoadProfile.new
  end

  # POST /load_profiles
  def create
    respond_with(@load_profile = current_user.load_profiles
                                  .create(load_profile_params))
  end

  # GET /load_profiles/:id/edit
  def edit
    PrivatePolicy.new(self, @load_profile).authorize
  end

  # PATCH /load_profiles/:id
  def update
    if PrivatePolicy.new(self, @load_profile).authorized?
      @load_profile.update_attributes(load_profile_params)

      respond_with(@load_profile)
    else
      redirect_to load_profiles_path
    end
  end

  # DELETE /load_profiles/:id
  def destroy
    if PrivatePolicy.new(self, @load_profile).authorized?
      @load_profile.destroy
      redirect_to(load_profiles_url)
    else
      redirect_to load_profiles_path
    end
  end

  #######
  private
  #######

  def fetch_load_profile
    @load_profile = LoadProfile.find(params[:id])
  end

  def load_profile_params
    params.require(:load_profile).permit(
      :key, :name, :curve, :load_profile_category_id,
      { technology_profiles_attributes: [:id, :technology, :_destroy] }
    )
  end
end
