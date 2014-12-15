# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Topology.create(graph: [{
  'name' =>  'HV Network',
  'children' => [
    {
      'name' => 'Medium Voltage #1',
      'children' => [
        { 'name' => 'MV Connection #1' },
        { 'name' => 'Low Voltage #1' },
        { 'name' => 'Low Voltage #2' }
      ]
    }, {
      'name' => 'Medium Voltage #2',
      'children' => [
        { 'name' => 'Low Voltage #3' },
        { 'name' => 'Low Voltage #4' },
        { 'name' => 'Low Voltage #5' }
      ]
    }
  ]
}])
