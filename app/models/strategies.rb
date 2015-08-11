module Strategies
  def self.all
    [
      { name: "prioritize_local_solar_production",         ajax_prop: 'solar_storage', enabled: true },
      { name: "prioritize_local_solar_battery_production", ajax_prop: 'battery_storage', enabled: true},
      { name: "conversion_local_solar_power_to_heat",      ajax_prop: "solar_power_to_heat", enabled: true},
      { name: "conversion_local_solar_power_to_gas",       ajax_prop: "solar_power_to_gas", enabled: true},
      { name: "buffering_local_solar_electric_car",        ajax_prop: "buffering_electric_car", enabled: true},
      { name: "buffering_local_solar_heat_pumps",          ajax_prop: "buffering_heat_pumps", enabled: true},
      { name: "postponing_base_load",                      ajax_prop: "postponing_base_load", enabled: true},
      { name: "saving_aggregated_base_load",               ajax_prop: "saving_base_load", enabled: true},
      { name: "capping_solar_pv",                          ajax_prop: "capping_solar_pv", enabled: true}
    ]
  end
end
