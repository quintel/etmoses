require 'rails_helper'

RSpec.describe Import::DemandCalculator do
  describe 'single gquery key' do
    let(:gqueries) {
      {
        "heat_demand_in_households"=>{
          "present" => 0.0001,
          "future"  => 0.0001,
          "unit"    =>"PJ"
        }
      }
    }

    it 'calculating heat demand' do
      expect(Import::DemandCalculator.new(1, 10, gqueries).calculate)
        .to eq(2777.7777777777778)
    end
  end

  describe 'multiple gquery keys' do
    let(:gqueries) {
      {
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
      }
    }

    it 'calculating heat demand' do
      expect(Import::DemandCalculator.new(1, 10, gqueries).calculate)
        .to eq(5555.555555555556)
    end
  end
end
