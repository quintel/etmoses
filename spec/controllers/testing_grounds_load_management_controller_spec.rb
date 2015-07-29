require 'rails_helper'

RSpec.describe TestingGroundsController do
  describe "applying strategies" do
    let!(:profiles){
      solar_load_profile = FactoryGirl.create(:load_profile_with_curve, key: "solar_pv_zwolle")
      ev_load_profile = FactoryGirl.create(:load_profile_with_curve, key: "ev_profile_11_3.7_kw")
      FactoryGirl.create(:technology_profile, technology: 'households_solar_pv_solar_radiation', load_profile: solar_load_profile)
      FactoryGirl.create(:technology_profile, technology: 'transport_car_using_electricity', load_profile: ev_load_profile)
    }
    let(:testing_ground){ FactoryGirl.create(:testing_ground, technology_profile: fake_technology_profile) }

    it "applies storage" do
      get :data, format: :json, id: testing_ground.id, strategies: {
        "storage"=>true,
        "battery_storage"=>false,
        "solar_power_to_heat"=>false,
        "solar_power_to_gas"=>false,
        "buffering_electric_car"=>false,
        "buffering_space_heating"=>false,
        "buffering_hot_water"=>false,
        "postponing_base_load"=>false,
        "saving_base_load"=>false,
        "capping_solar_pv"=>false,
        'capping_fraction'=> 0.5
      }
    end
  end
end
