require 'rails_helper'

RSpec.describe TechnologyProfileCalculationDecorator do
  let(:technology_list) {
    TechnologyList.new("Households 1" => technologies)
  }

  let(:decorated) {
    TechnologyProfileCalculationDecorator.new(technology_list).decorate
  }

  describe "basic technology" do
    let(:technologies) {
      [ InstalledTechnology.new(type: "base_load") ]
    }

    it 'decorates a technology list with a base_load' do
      expect(decorated.list.values.flatten.size).to eq(1)
    end
  end

  describe "hhp" do
    let(:technologies) {
      [
        InstalledTechnology.new(
          type: 'households_water_heater_hybrid_heatpump_air_water_electricity',
          buffer: "buffer_space_heating_1",
          initial_investment: 5000,
          components: [
            { type: 'households_water_heater_hybrid_heatpump_air_water_electricity_electricity',
              capacity: 5.0 },
            { type: 'households_space_heater_hybrid_heatpump_air_water_electricity_gas',
              capacity: 1.0 }
          ]
        )
      ]
    }

    it 'decorates a technology list with a hhp turns into two technologies' do
      expect(decorated.list.values.flatten.size).to eq(2)
    end

    it 'decorates a technology list with a hhp sets the correct buffers' do
      expect(decorated.list.values.flatten.map(&:buffer)).to eq([
        'buffer_space_heating_1', 'buffer_space_heating_1'
      ])
    end
  end
end
