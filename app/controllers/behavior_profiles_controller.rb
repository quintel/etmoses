class BehaviorProfilesController < ProfilesController
  def profile_params
    params.require(:behavior_profile).permit(:key, :type, :name, :curve, :public)
  end
end
