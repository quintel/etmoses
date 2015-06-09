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
  import_from: 'electricity_output_capacity',
  export_to:   'households_solar_pv_solar_radiation_market_penetration'
)

Technology.create!(
  key:         'households_space_heater_heatpump_air_water_electricity',
  name:        'Heat pump for space heating (air)',
  import_from: 'input_capacity',
  export_to:   'households_space_heater_heatpump_air_water_electricity_share'
)

Technology.create!(
  key:         'households_space_heater_heatpump_ground_water_electricity',
  name:        'Heat pump for space heating (ground)',
  import_from: 'input_capacity',
  export_to:   'households_space_heater_heatpump_ground_water_electricity_share'
)

Technology.create!(
  key:         'households_water_heater_heatpump_air_water_electricity',
  name:        'Heat pump for hot water (air)',
  import_from: 'input_capacity',
  export_to:   'households_water_heater_heatpump_air_water_electricity_share'
)

Technology.create!(
  key:         'households_water_heater_heatpump_ground_water_electricity',
  name:        'Heat pump for hot water (ground)',
  import_from: 'input_capacity',
  export_to:   'households_water_heater_heatpump_ground_water_electricity_share'
)

Technology.create!(
  key:         'transport_car_using_electricity',
  name:        'Electric car',
  import_from: 'input_capacity',
  export_to:   'transport_car_using_electricity_share'
)

Technology.create!(
  key:         'base_load',
  name:        'Household'
)

Technology.create!(
  key:         'generic',
  name:        'Other'
)

# Example Testing Ground
# ----------------------

graph = <<-YML
---
name: MV Network
children:
- name: 'LV #1'
- name: 'LV #2'
  children:
  - name: Office Building
  - name: Home
- name: 'LV #3'
YML

technologies = <<-YML
---
'LV #1':
- name: Heat Pump Type 1
  load: -2.5
- name: Electric Car
  load: 8.2
'Office Building':
- name: Heat Pump Type 1
  load: -2.5
- name: Solar Panel
  load: -1.5
- name: Server Farm
  load: 6.6
- name: Coffee Machine
  load: 1.3
'Home':
- name: Heat Pump Type 1
  load: -2.5
- name: Solar Panel
  load: -1.5
- name: Washing Machine
  load: 2.1
- name: Electric Oven
  load: 3.1
'LV #3':
- name: Heat Pump Type 2
  load: -3.5
- name: Solar Panel
  load: -1.5
- name: Electric Car
  load: 8.2
YML

TestingGround.create!(
  topology:     Topology.create!(graph: YAML.load(graph)),
  technologies: YAML.load(technologies)
)
