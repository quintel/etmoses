require 'rails_helper'

RSpec.describe Import::HybridExpander do
  let(:expansion) { Import::HybridExpander.new(hybrids).expand }

  describe 'expands hybrid technologies into their gas and electricity counter parts' do
    let(:hybrids) {
      [{ 'type' => 'households_water_heater_hybrid_heatpump_air_water_electricity',
         'units' => 1 }]
    }

    it "expands into a 'gas' and 'electricity' type" do
      expect(expansion).to eq([
        {
          "type"=>"households_water_heater_hybrid_heatpump_air_water_electricity_electricity",
          "name"=>"Hybrid heat pump hot water (electricity)",
          "units"=>1,
          "carrier"=>"electricity",
          "position_relative_to_buffer"=>"buffering"
        },
        {
          "type"=>"households_water_heater_hybrid_heatpump_air_water_electricity_gas",
          "name"=>"Hybrid heat pump hot water (gas)",
          "units"=>1,
          "carrier"=>"gas",
          "position_relative_to_buffer"=>"boosting"
        }
      ])
    end
  end
end
