module BehaviorProfilesHelper
  def options_for_behavior_profiles(selected)
    options_for_select(BehaviorProfile.pluck(:name, :id), selected: selected)
  end
end
