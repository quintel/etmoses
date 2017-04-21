require 'rails_helper'

RSpec.describe Import::HouseBuilder do
  let(:response) { nil }

  let(:gqueries) {
    {
      "etmoses_electricity_base_load_demand"=>{
        "present"=>90.11341999999999,
        "future"=>99.05439142786325,
        "unit"=>"PJ"
      },
      'number_of_residences' => {
        'present' => 0.0,
        'future'  => 5.0,
        'unit'    => 'number'
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
end
