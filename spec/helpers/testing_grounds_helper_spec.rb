require 'rails_helper'

RSpec.describe TestingGroundsHelper do
  it 'lists all default technologies' do
    testing_ground = FactoryGirl.build(:testing_ground, technologies: nil)
    expect(technologies_field_value(testing_ground)).to eq(TestingGround::DEFAULT_TECHNOLOGIES)
  end

  describe 'lists all existing technologies as yaml without the nodes and profiles' do
    let(:testing_ground){ FactoryGirl.build(:testing_ground,
      technologies: testing_ground_technologies_without_profiles) }

    it "validating the output of the yaml" do
      expect(technologies_field_value(testing_ground)).to eq(<<-eos
---
- type: households_solar_pv_solar_radiation
  name: Residential PV panel
  units: 200
  capacity: 1.5
- type: households_space_heater_heatpump_air_water_electricity
  name: Heat pump for space heating (air)
  units: 2
  capacity: 10.0
- type: households_space_heater_heatpump_ground_water_electricity
  name: Heat pump for space heating (ground)
  units: 2
  capacity: 10.0
- type: households_water_heater_heatpump_air_water_electricity
  name: Heat pump for hot water (air)
  units: 2
  capacity: 10.0
- type: households_water_heater_heatpump_ground_water_electricity
  name: Heat pump for hot water (ground)
  units: 2
  capacity: 10.0
- type: transport_car_using_electricity
  name: Electric car
  capacity: 3.7
- type: transport_car_using_electricity
  capacity: 3.7
  eos
)
    end

    it "lists 7 different types of technologies" do
      expect(YAML.load(technologies_field_value(testing_ground)).count).to eq(7)
    end
  end
end
