# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

graph = <<-YML
---
- name: MV Network
  children:
  - name: 'LV #1'
    children:
    - technology: heat_pump_1
  - name: 'LV #2'
    children:
    - name: Office Building
      children:
      - technology: heat_pump_1
      - technology: solar_panel_1
    - name: Home
      children:
      - technology: heat_pump_1
      - technology: solar_panel_1
  - name: 'LV #3'
    children:
    - technology: heat_pump_2
    - technology: solar_panel_1
YML

technologies = <<-YML
---
heat_pump_1:
  name: Heat Pump Type 1
  efficiency: 4.0
  capacity: 2.5
heat_pump_2:
  name: Heat Pump Type 2
  efficiency: 4.5
  capacity: 3.5
solar_panel_1:
  name: Solar Panel
  efficiency: 1.0
  capacity: 1.5
YML

Topology.create!(graph: YAML.load(graph), technologies: YAML.load(technologies))
