require 'rails_helper'

RSpec.describe Import::BuildingsBuilder do
  let(:testing_ground){ FactoryGirl.create(:testing_ground, scenario_id: 1) }

  let(:gqueries) {
    {
      'number_of_buildings' => {
        'present' => 2.123, 'future' => 2.1312 },
      'present_demand_in_source_of_electricity_in_buildings' => {
        'present' => 0.0000123, 'future' => 0.0000123 }
    }
  }

  it 'builds a set of buildings' do
    buildings_builder = Import::BuildingsBuilder.new(gqueries,
      id: testing_ground.scenario_id,
      scaling: {})

    expect(buildings_builder.build(nil)).to eq([{
      "name"     => "Buildings",
      "type"     => "base_load_buildings",
      "profile"  => nil,
      "capacity" => nil,
      "demand"   => 1708.33,
      "units"    => 2 }
    ])
  end
end
