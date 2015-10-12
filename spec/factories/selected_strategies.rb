FactoryGirl.define do
  factory :selected_strategy do
    solar_storage false
    battery_storage false
    solar_power_to_heat false
    solar_power_to_gas false
    buffering_electric_car false
    buffering_space_heating false
    postponing_base_load false
    saving_base_load false
    capping_solar_pv false
    capping_fraction 1
  end
end
