class LoadProfilesController < ApplicationController
  respond_to :html
  respond_to :json, only: :show

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
    @load_profile = LoadProfile.find(params[:id])
  end

  # PATCH /load_profiles/:id
  def update
    @load_profile = LoadProfile.find(params[:id])
    @load_profile.update_attributes(load_profile_params)

    respond_with(@load_profile)
  end

  #######
  private
  #######

  def load_profile_params
    params.require(:load_profile).permit(:key, :name, :curve)
  end
end
