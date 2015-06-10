require 'rails_helper'

RSpec.describe TestingGround::ConcurrencyCalculator do
  let(:topology){ FactoryGirl.create(:topology).graph.to_json }
  let!(:technology_profiles){
    5.times do
      FactoryGirl.create(:technology_profile,
                          technology: "households_solar_pv_solar_radiation")
    end
  }

  it 'minimizes concurrency' do
    new_profile = TestingGround::ConcurrencyCalculator.new(
                    profile, topology, false
                  ).calculate

    expect(new_profile.values.flatten.map{|t| t['profile'] }.uniq.count).to eq(2)
  end

  def profile
    JSON.dump({
      "lv1" => [{
        "name"=>"Residential PV panel",
        "type"=>"households_solar_pv_solar_radiation",
        "profile"=>"solar_pv_zwolle",
        "capacity"=>"-1.5",
        "units"=>"1.0"
      }],
      "lv2" => [{
        "name"=>"Residential PV panel",
        "type"=>"households_solar_pv_solar_radiation",
        "profile"=>"solar_pv_zwolle",
        "capacity"=>"-1.5",
        "units"=>"1.0"
      }]
    })
  end
end
