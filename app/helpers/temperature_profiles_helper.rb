module TemperatureProfilesHelper
  def options_for_temperature_profiles(selected)
    options_for_select(TemperatureProfile.pluck(:name, :id), selected: selected)
  end
end
