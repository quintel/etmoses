require 'rails_helper'

RSpec.describe Import::HybridBuilder do
  let(:expansion) {
    Import::HybridBuilder.new({}, id: 1, scaling: { value: 1 }).build(hybrids)
  }

  describe 'expands hybrid technologies into their gas and electricity counter parts' do
    let(:hybrids) {
      [{ 'type' => 'households_water_heater_hybrid_heatpump_air_water_electricity',
         'carrier' => 'hybrid',
         'units' => 1 }]
    }

    it "expands into 2 technologies" do
      expect(expansion[0]['components'].size).to eq(2)
    end

    it "expands into a 'gas' and 'electricity' type" do
      expect(expansion[0]['components'].map{|e| e['type'] }).to eq([
        "households_water_heater_hybrid_heatpump_air_water_electricity_electricity",
        "households_water_heater_hybrid_heatpump_air_water_electricity_gas"
      ])
    end
  end
end
