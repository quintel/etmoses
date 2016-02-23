require 'rails_helper'

RSpec.describe TechnologyProfiles::Query do
  let!(:technology_profile) {
    FactoryGirl.create(:technology_profile,
                        technology: "households_solar_pv_solar_radiation",
                        load_profile: load_profile)
  }

  let(:query) {
    TechnologyProfiles::Query.new(
      [{'type' => 'households_solar_pv_solar_radiation'}]).query
  }

  describe "with allowed technology profiles for concurrency" do
    let(:load_profile){ FactoryGirl.create(:load_profile,
      included_in_concurrency: false
    ) }

    it "queries the technology profiles of a solar pv" do
      expect(query).to eq({"households_solar_pv_solar_radiation"=>[]})
    end
  end

  describe "with non-allowed technology profiles for concurrency" do
    let(:load_profile){
      FactoryGirl.create(:load_profile)
    }

    it "queries the technology profiles of a solar pv" do
      expect(query).to eq({
        "households_solar_pv_solar_radiation"=>[load_profile.id]
      })
    end
  end
end
