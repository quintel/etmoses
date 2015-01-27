# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

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
  capacity: 2.5
- name: Electric Car
  demand: 8.2
'Office Building':
- name: Heat Pump Type 1
  capacity: 2.5
- name: Solar Panel
  capacity: 1.5
- name: Server Farm
  demand: 6.6
- name: Coffee Machine
  demand: 1.3
'Home':
- name: Heat Pump Type 1
  capacity: 2.5
- name: Solar Panel
  capacity: 1.5
- name: Washing Machine
  demand: 2.1
- name: Electric Oven
  demand: 3.1
'LV #3':
- name: Heat Pump Type 2
  capacity: 3.5
- name: Solar Panel
  capacity: 1.5
- name: Electric Car
  demand: 8.2
YML

Topology.create!(graph: YAML.load(graph), technologies: YAML.load(technologies))
