require 'rails_helper'

RSpec.describe Import::DemandCalculator do
  describe 'single gquery key' do
    before do
      stub_et_gquery({
        "heat_demand_in_households"=>{
          "present" => 0.0001,
          "future"  => 0.0001,
          "unit"    =>"PJ"
        }
      })
    end

    it 'calculating heat demand' do
      expect(Import::DemandCalculator.new(1, 10, %w(heat_demand_in_households)).calculate)
        .to eq(2777.78)
    end
  end

  describe 'multiple gquery keys' do
    before do
      stub_et_gquery({
        "heat_demand_in_households"=>{
          "present" => 0.0001,
          "future"  => 0.0001,
          "unit"    => "PJ"
        },
        "hot_water_demand_in_households"=>{
          "present" => 0.0001,
          "future"  => 0.0001,
          "unit"    => "PJ"
        }
      })
    end

    it 'calculating heat demand' do
      expect(Import::DemandCalculator.new(1, 10,
        %w(heat_demand_in_households hot_water_demand_in_households)).calculate)
        .to eq(5555.56)
    end
  end
end
