# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Starting Technologies
# ---------------------

Technology.create!(
  key:         'households_solar_pv_solar_radiation',
  name:        'Residential PV panel',
  export_to:   'households_solar_pv_solar_radiation_market_penetration',
  behavior:    'conserving'
)

Technology.create!(
  key:         'households_space_heater_heatpump_air_water_electricity',
  name:        'Heat pump for space heating (air)',
  export_to:   'households_space_heater_heatpump_air_water_electricity_share',
  behavior:    'buffer'
)

Technology.create!(
  key:         'households_space_heater_heatpump_ground_water_electricity',
  name:        'Heat pump for space heating (ground)',
  export_to:   'households_space_heater_heatpump_ground_water_electricity_share',
  behavior:    'buffer'
)

Technology.create!(
  key:         'households_water_heater_heatpump_air_water_electricity',
  name:        'Heat pump for hot water (air)',
  export_to:   'households_water_heater_heatpump_air_water_electricity_share',
  behavior:    'buffer'
)

Technology.create!(
  key:         'households_water_heater_heatpump_ground_water_electricity',
  name:        'Heat pump for hot water (ground)',
  export_to:   'households_water_heater_heatpump_ground_water_electricity_share',
  behavior:    'buffer'
)

Technology.create!(
  key:         'transport_car_using_electricity',
  name:        'Electric car',
  export_to:   'transport_car_using_electricity_share',
  behavior:    'electric_vehicle'
)

Technology.create!(
  key:         'battery',
  name:        'Generic Battery',
  behavior:    'storage'
)

Technology.create!(
  key:         'households_flexibility_p2p_electricity',
  name:        'Battery',
  export_to:   'households_flexibility_p2p_electricity_market_penetration',
  behavior:    'storage'
)

Technology.create!(
  key:         'energy_flexibility_p2g_electricity',
  name:        'Power-To-Gas',
  export_to:   'number_of_energy_flexibility_p2g_electricity',
  behavior:    'siphon'
)

Technology.create!(
  key:         'households_flexibility_p2h_electricity',
  name:        'Power-To-Heat',
  export_to:   'households_flexibility_p2h_electricity_market_penetration',
  behavior:    'optional_buffer'
)

Technology.create!(
  key:         'base_load',
  name:        'Household',
  behavior:    'base_load'
)

Technology.create!(
  key:         'base_load_buildings',
  name:        'Buildings',
  behavior:    'base_load_buildings'
)

Technology.create!(
  key:         'generic',
  name:        'Other'
)

