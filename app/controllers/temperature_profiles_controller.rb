class TemperatureProfilesController < ProfilesController
  def profile_params
    params.require(:temperature_profile).permit(:key, :type, :name, :curve, :public)
  end
end
