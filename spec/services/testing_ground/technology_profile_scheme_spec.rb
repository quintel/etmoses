require 'rails_helper'

RSpec.describe TestingGround::TechnologyProfileScheme do
  let(:topology){ FactoryGirl.build(:topology).graph }

  let!(:technology_profiles){
    5.times do |i|
      load_profile = FactoryGirl.create(:load_profile, key: i)
      FactoryGirl.create(:technology_profile,
                          technology: "households_solar_pv_solar_radiation",
                          load_profile: load_profile)
    end
  }

  # Maximum concurrency
  describe "maximum concurrency" do
    it "maximizes profile concurrency by counting the keys in sequence" do
      technology_distribution = TestingGround::TechnologyDistributor.new(
        testing_ground_technologies_without_profiles, topology).build

      technology_profile_scheme = TestingGround::TechnologyProfileScheme.new(
        technology_distribution, false
      ).build

      expect(
        technology_profile_scheme.values.flatten.map{|t| t['profile'] }.compact
      ).to eq(%w(0 1 2 3 4 0 1 2))
    end
  end
end
