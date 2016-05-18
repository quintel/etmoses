require 'rails_helper'

RSpec.describe Import::HouseBuilder do
  let(:response) { nil }

  let(:gqueries) {
    {
      "etmoses_electricity_base_load_demand"=>{
        "present"=>90.11341999999999,
        "future"=>99.05439142786325,
        "unit"=>"PJ"
      }
    }
  }

  describe "#number_of_residence" do
    it 'builds 5 houses for scaling attributes' do
      expect(Import::HouseBuilder.new(gqueries, { id: 1, scaling: {
        "area_attribute"=>"number_of_residences",
        "value"=>5.0,
        "has_agriculture"=>true,
        "has_industry"=>false
      }}).build(response)[0]['units']).to eq(5)
    end
  end

  describe "#number_of_inhabitants" do
    it 'builds a house for scaling attributes' do
      expect(Import::HouseBuilder.new(gqueries, { id: 1, scaling: {
        "area_attribute"=>"number_of_inhabitants",
        "value"=>5.0,
        "has_agriculture"=>true,
        "has_industry"=>false
      }}).build(response)).to eq([])
    end
  end

  describe "#nil" do
    it "doesn't build a house for scaling attributes" do
      expect(Import::HouseBuilder.new(gqueries, { id: 1, scaling: nil}
        ).build(response)).to eq([])
    end
  end
end
