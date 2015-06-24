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
  export_to:   'households_solar_pv_solar_radiation_market_penetration'
)

Technology.create!(
  key:         'households_space_heater_heatpump_air_water_electricity',
  name:        'Heat pump for space heating (air)',
  export_to:   'households_space_heater_heatpump_air_water_electricity_share'
)

Technology.create!(
  key:         'households_space_heater_heatpump_ground_water_electricity',
  name:        'Heat pump for space heating (ground)',
  export_to:   'households_space_heater_heatpump_ground_water_electricity_share'
)

Technology.create!(
  key:         'households_water_heater_heatpump_air_water_electricity',
  name:        'Heat pump for hot water (air)',
  export_to:   'households_water_heater_heatpump_air_water_electricity_share'
)

Technology.create!(
  key:         'households_water_heater_heatpump_ground_water_electricity',
  name:        'Heat pump for hot water (ground)',
  export_to:   'households_water_heater_heatpump_ground_water_electricity_share'
)

Technology.create!(
  key:         'transport_car_using_electricity',
  name:        'Electric car',
  export_to:   'transport_car_using_electricity_share'
)

Technology.create!(
  key:         'base_load',
  name:        'Household'
)

Technology.create!(
  key:         'base_load_buildings',
  name:        'Buildings'
)

Technology.create!(
  key:         'generic',
  name:        'Other'
)

