module Strategies
  def self.all
    [
      { name: "prioritize_local_solar_battery_production", ajax_prop: 'battery_storage', enabled: true},
      { name: "ev_capacity_constrained",                   ajax_prop: 'ev_capacity_constrained', enabled: true },
      { name: "ev_excess_constrained",                     ajax_prop: 'ev_excess_constrained', enabled: true },
      { name: "ev_storage",                                ajax_prop: 'ev_storage', enabled: true },
      { name: "conversion_local_solar_power_to_heat",      ajax_prop: "solar_power_to_heat", enabled: true},
      { name: "conversion_local_solar_power_to_gas",       ajax_prop: "solar_power_to_gas", enabled: true},
      { name: "hp_capacity_constrained",                   ajax_prop: "hp_capacity_constrained", enabled: true},
      { name: "postponing_base_load",                      ajax_prop: "postponing_base_load", enabled: true},
      { name: "saving_aggregated_base_load",               ajax_prop: "saving_base_load", enabled: true},
      { name: "capping_solar_pv",                          ajax_prop: "capping_solar_pv", enabled: true},
      { name: "hhp_switch_to_gas",                         ajax_prop: "hhp_switch_to_gas", enabled: true}
    ]
  end
end
