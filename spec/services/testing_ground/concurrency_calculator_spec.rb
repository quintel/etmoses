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
      technology_distribution, false
    ).calculate

    expect(new_profile.values.flatten.map{|t| t['profile'] }.uniq.count).to eq(2)
  end

  describe "maximizes concurrency" do
    let(:new_profile){
      TestingGround::ConcurrencyCalculator.new(
        minimized_technology_distribution
      ).calculate
    }

    it "expects only one profile" do
      expect(new_profile.values.flatten.map{|t| t['profile'] }.uniq.count).to eq(1)
    end

    it "expects no duplicate entries per node" do
      expect(new_profile.values.flatten.length).to eq(2)
    end
  end

  def minimized_technology_distribution
    JSON.dump([{
      "name"=>"Residential PV panel",
      "type"=>"households_solar_pv_solar_radiation",
      "profile"=>"solar_pv_zwolle",
      "capacity"=>"-1.5",
      "units"=>"1.0",
      "node"=>"lv1"
    },
    {
      "name"=>"Residential PV panel",
      "type"=>"households_solar_pv_solar_radiation",
      "profile"=>"solar_pv_ameland",
      "capacity"=>"-1.5",
      "units"=>"1.0",
      "node"=>"lv1"
    },
    {
      "name"=>"Residential PV panel",
      "type"=>"households_solar_pv_solar_radiation",
      "profile"=>"solar_pv_zwolle",
      "capacity"=>"-1.5",
      "units"=>"1.0",
      "node"=>"lv2"
    },
    {
      "name"=>"Residential PV panel",
      "type"=>"households_solar_pv_solar_radiation",
      "profile"=>"solar_pv_ameland",
      "capacity"=>"-1.5",
      "units"=>"1.0",
      "node"=>"lv2"
    }
    ])
  end

  def technology_distribution
    JSON.dump([{
      "name"=>"Residential PV panel",
      "type"=>"households_solar_pv_solar_radiation",
      "profile"=>"solar_pv_zwolle",
      "capacity"=>"-1.5",
      "units"=>"1.0",
      "node"=>"lv1"
    },
    {
      "name"=>"Residential PV panel",
      "type"=>"households_solar_pv_solar_radiation",
      "profile"=>"solar_pv_zwolle",
      "capacity"=>"-1.5",
      "units"=>"1.0",
      "node"=>"lv2"
    }])
  end
end
