require 'rails_helper'

RSpec.describe Export do
  let(:topology){ FactoryGirl.create(:topology) }
  let!(:technologies){
    FactoryGirl.create(:technology, key: "households_solar_pv_solar_radiation")
    FactoryGirl.create(:technology, key: "transport_car_using_electricity")
  }
  let(:testing_ground){
    FactoryGirl.create(:testing_ground, topology: topology,
      technology_profile: profile_json)
  }

  it "exports an export" do
    stub_et_engine_scenario_create_request
    stub_et_engine_scenario_update_request

    expect(Export.new(testing_ground).export).to eq({"id" => 2})
  end
end
