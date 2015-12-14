# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Starting Technologies
# ---------------------

Technology.create!(
  key:         'households_solar_pv_solar_radiation',
  name:        'Residential PV panel',
  export_to:   'households_solar_pv_solar_radiation_market_penetration',
  carrier:     'electricity',
  behavior:    'conserving'
)

Technology.create!(
  key:         'transport_car_using_electricity',
  name:        'Electric car',
  export_to:   'transport_car_using_electricity_share',
  carrier:     'electricity',
  behavior:    'electric_vehicle'
)

Technology.create!(
  key:         'battery',
  name:        'Generic Battery',
  carrier:     'electricity',
  behavior:    'storage'
)

Technology.create!(
  key:         'households_flexibility_p2p_electricity',
  name:        'Battery',
  export_to:   'households_flexibility_p2p_electricity_market_penetration',
  carrier:     'electricity',
  behavior:    'storage'
)

Technology.create!(
  key:         'energy_flexibility_p2g_electricity',
  name:        'Power-To-Gas',
  export_to:   'number_of_energy_flexibility_p2g_electricity',
  carrier:     'electricity',
  behavior:    'siphon'
)

Technology.create!(
  key:         'households_flexibility_p2h_electricity',
  name:        'Power-To-Heat',
  export_to:   'households_flexibility_p2h_electricity_market_penetration',
  carrier:     'electricity',
  behavior:    'optional_buffer'
)

Technology.create!({
  key:      "base_load_edsn",
  name:     "Household aggregated",
  carrier:  'electricity',
  behavior: "optional",
  visible:  false
})

base_load = Technology.create!(
  key:         'base_load',
  name:        'Household',
  carrier:     'electricity',
  behavior:    'base_load'
)

TechnologyComponentBehavior.create!(
  technology:  base_load,
  curve_type: 'flex',
  behavior:   'deferrable'
)

TechnologyComponentBehavior.create!(
  technology:  base_load,
  curve_type: 'inflex',
  behavior:   'generic'
)

base_load_buildings = Technology.create!(
  key:         'base_load_buildings',
  name:        'Buildings',
  carrier:     'electricity',
  behavior:    'base_load_buildings'
)

TechnologyComponentBehavior.create!(
  technology:  base_load_buildings,
  curve_type: 'flex',
  behavior:   'optional'
)

TechnologyComponentBehavior.create!(
  technology:  base_load_buildings,
  curve_type: 'inflex',
  behavior:   'generic'
)

Technology.create!(
  key:         'generic',
  name:        'Other',
  carrier:     'electricity',
)

hp_sh_aw = Technology.create!(
  key:         'households_space_heater_heatpump_air_water_electricity',
  name:        'Heat pump for space heating (air)',
  export_to:   'households_space_heater_heatpump_air_water_electricity_share',
  behavior:    'buffer',
  carrier:     'electricity',
  default_position_relative_to_buffer: "buffering"
)

hp_sh_gw = Technology.create!(
  key:         'households_space_heater_heatpump_ground_water_electricity',
  name:        'Heat pump for space heating (ground)',
  export_to:   'households_space_heater_heatpump_ground_water_electricity_share',
  behavior:    'buffer',
  carrier:     'electricity',
  default_position_relative_to_buffer: "buffering"
)

hp_sh_ng = Technology.create!(
  key:         'households_space_heater_network_gas',
  name:        'Households space heater network gas',
  carrier:     'gas',
  default_position_relative_to_buffer: "boosting"
)

hp_sh_cng = Technology.create!(
  key:         'households_space_heater_combined_network_gas',
  name:        'Households space heater combined network gas',
  carrier:     'gas',
  default_position_relative_to_buffer: "boosting"
)

hp_wh_aw = Technology.create!(
  key:         'households_water_heater_heatpump_air_water_electricity',
  name:        'Heat pump for hot water (air)',
  export_to:   'households_water_heater_heatpump_air_water_electricity_share',
  behavior:    'buffer',
  carrier:     'electricity',
  default_position_relative_to_buffer: "buffering"
)

hp_wh_gw = Technology.create!(
  key:         'households_water_heater_heatpump_ground_water_electricity',
  name:        'Heat pump for hot water (ground)',
  export_to:   'households_water_heater_heatpump_ground_water_electricity_share',
  behavior:    'buffer',
  carrier:     'electricity',
  default_position_relative_to_buffer: "buffering"
)

buffer_space_heating = Technology.create!({
  key:       "buffer_space_heating",
  name:      "Buffer space heating",
  carrier:   "electricity",
  composite: true,
})

[hp_sh_aw, hp_sh_gw, hp_sh_ng, hp_sh_cng].each do |tech|
  Composite.create!(composite: buffer_space_heating, technology: tech)
end

buffer_water_heating = Technology.create!({
  key:       "buffer_water_heating",
  name:      "Buffer water heating",
  carrier:   "electricity",
  composite: true
})

[hp_wh_aw, hp_wh_gw].each do |tech|
  Composite.create!(composite: buffer_water_heating, technology: tech)
end

# Hybrid heat pump space heater
Technology.create!({
  key: 'households_space_heater_hybrid_heatpump_air_water_electricity',
  name: "Hybrid heat pump space heating",
  carrier: "hybrid",
  visible: false
})

Technology.create!({
  key: 'households_space_heater_hybrid_heatpump_air_water_electricity_electricity',
  name: "Hybrid heat pump space heating (electricity)",
  carrier: "electricity",
  default_capacity: 4.9,
  default_position_relative_to_buffer: "buffering"
})

Technology.create!({
  key: 'households_space_heater_hybrid_heatpump_air_water_electricity_gas',
  name: "Hybrid heat pump space heating (gas)",
  carrier: "gas",
  default_capacity: 15.0,
  default_position_relative_to_buffer: "boosting"
})

# Hybrid heat pump water
Technology.create!({
  key: 'households_water_heater_hybrid_heatpump_air_water_electricity',
  name: "Hybrid heat pump hot water",
  carrier: "hybrid",
  visible: false
})

Technology.create!({
  key: 'households_water_heater_hybrid_heatpump_air_water_electricity_electricity',
  name: "Hybrid heat pump hot water (electricity)",
  carrier: "electricity",
  default_capacity: 4.9,
  default_position_relative_to_buffer: "buffering"
})

Technology.create!({
  key: 'households_water_heater_hybrid_heatpump_air_water_electricity_gas',
  name: "Hybrid heat pump space heating (gas)",
  carrier: "gas",
  default_capacity: 15.0,
  default_position_relative_to_buffer: "boosting"
})

User.create!(
  email: 'guest@quintel.com',
  password: 'guest'
)

password = SecureRandom.hex[0..16]

User.create!(
  email: "orphan@quintel.com",
  name: "ETMoses",
  password: password
)

[ "aggregator", "cooperation", "customer", "government", "producer", "supplier",
  "system operator"
].each do |name|
  Stakeholder.create!(name: name)
end

customer = Stakeholder.find_by_name("Customer")
8.times do |i|
  ['', 'a', 'b'].each do |suffix|
    Stakeholder.create!(name: "customer AC#{i + 1}#{suffix}", parent_id: customer.id)
  end
end
