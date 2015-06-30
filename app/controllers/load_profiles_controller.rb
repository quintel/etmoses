class LoadProfilesController < ProfilesController
  def new
    @profile = LoadProfile.new
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
end
