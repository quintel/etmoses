class LoadProfilesController < ApplicationController
  respond_to :html
  respond_to :json, only: :show

  before_filter :fetch_load_profile, except: [:index, :new, :create]

  # GET /load_profiles
  def show
    respond_with(@load_profile = LoadProfile.find(params[:id]))
  end

  # GET /load_profiles/new
  def new
    @load_profile = LoadProfile.new
  end

  # POST /load_profiles
  def create
    respond_with(@load_profile = LoadProfile.create(load_profile_params))
  end

  # GET /load_profiles/:id/edit
  def edit
    # @load_profile = LoadProfile.find(params[:id])
  end

  # PATCH /load_profiles/:id
  def update
    # @load_profile = LoadProfile.find(params[:id])
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
  end

  def load_profile_params
    params.require(:load_profile).permit(
      :key, :name, :curve,
      { technology_profiles_attributes: [:id, :technology, :_destroy] }
    )
  end
end
