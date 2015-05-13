require 'rails_helper'

RSpec.describe Import::HouseBuilder do
  before do
    stub_et_gquery
  end

  describe "#number_of_residence" do
    it 'builds 5 houses for scaling attributes' do
      expect(Import::HouseBuilder.new(1, {
        "area_attribute"=>"number_of_residences",
        "value"=>5.0,
        "has_agriculture"=>true,
        "has_industry"=>false
      }).build[0]['units']).to eq(5)
    end
  end

  describe "#number_of_inhabitants" do
    it 'builds a house for scaling attributes' do
      expect(Import::HouseBuilder.new(1, {
        "area_attribute"=>"number_of_inhabitants",
        "value"=>5.0,
        "has_agriculture"=>true,
        "has_industry"=>false
      }).build).to eq([])
    end
  end

  describe "#nil" do
    it "doesn't build a house for scaling attributes" do
      expect(Import::HouseBuilder.new(1, nil).build).to eq([])
    end
  end
end
