require 'rails_helper'

RSpec.describe TestingGround::TechnologyProfileScheme do
  let(:topology){ FactoryGirl.create(:topology).graph.to_json }

  describe "no buffers" do
    let!(:technology_profiles){
      5.times do
        FactoryGirl.create(:technology_profile,
                            technology: "households_solar_pv_solar_radiation")
      end

      5.times do
        FactoryGirl.create(:technology_profile,
                            technology: "transport_car_using_electricity")
      end
    }

    it 'minimizes concurrency' do
      new_profile = TestingGround::TechnologyProfileScheme.new(
        ProfileSchemeTestHelper.technology_distribution
      ).build

      expect(new_profile.values.flatten.map{|t| t['profile'] }.uniq.count).to eq(2)
    end

    describe "maximizes concurrency" do
      let(:new_profile){
        TestingGround::TechnologyProfileScheme.new(
          ProfileSchemeTestHelper.minimized_technology_distribution
        ).build
      }

      it "expects only one profile" do
        expect(new_profile.values.flatten.map{|t| t['profile'] }.uniq.count).to eq(1)
      end

      it "expects no duplicate entries per node" do
        expect(new_profile.values.flatten.length).to eq(2)
      end

      it "doesn't automatically fill in the demand" do
        expect(new_profile.values.flatten.map{|t| t['demand'] }).to eq([nil, nil])
      end
    end

    describe "minimizes concurrency with a subset of technologies" do
      let(:new_profile){
        TestingGround::TechnologyProfileScheme.new(JSON.parse(profile_json)).build
      }

      it "expects only the electric car to have minimum concurrency" do
        # (5 profiles for each electric car + 1 profile for each solar panel)
        # x 2 endpoints = 12
        expect(new_profile.values.flatten.length).to eq(12)
      end
    end

    describe "EDSN profile usage" do
      let!(:profiles){
        5.times do |i|
          FactoryGirl.create(:technology_profile,
            technology: 'base_load',
            load_profile: FactoryGirl.create(:load_profile, key: "anonimous_#{i + 1}"))

          FactoryGirl.create(:technology_profile,
            technology: 'base_load_edsn',
            load_profile: FactoryGirl.create(:load_profile, key: "edsn_#{i + 1}"))
        end
      }

      describe "minimizes concurrency only with EDSN profiles" do
        let(:new_profile){
          TestingGround::TechnologyProfileScheme.new(
            ProfileSchemeTestHelper.basic_edsn_houses(31.0)
          ).build
        }

        it 'expects only EDSN profiles' do
          load_profile_id = new_profile.values.flatten.first["profile"]

          expect(LoadProfile.find(load_profile_id).key).to eq("edsn_1")
        end

        it "doesn't minimize" do
          expect(new_profile.values.flatten.length).to eq(1)
        end
      end

      describe "minimizes concurrency only with non-EDSN profiles" do
        let(:new_profile){
          TestingGround::TechnologyProfileScheme.new(
            ProfileSchemeTestHelper.basic_houses(9.0)
          ).build
        }

        it 'only makes use of non-EDSN profiles' do
          load_profile_id = new_profile.values.flatten.first["profile"]

          expect(LoadProfile.find(load_profile_id).key).to eq("anonimous_1")
        end
      end
    end
  end

  describe "buffers" do
    let!(:technology_profiles){
      5.times do |i|
          FactoryGirl.create(:technology_profile,
            technology: 'buffer_space_heating',
            load_profile: FactoryGirl.create(:load_profile, key: "bsh_#{i + 1}"))
      end
    }

    let(:new_profile){
      TestingGround::TechnologyProfileScheme.new(profile_scheme).build
    }

    describe 'minimizes concurrency with buffers' do
      let(:profile_scheme){ ProfileSchemeTestHelper.technology_distribution_buffers }

      it 'minimizes concurrency with buffers' do
        expect(new_profile.values.flatten.map{|t| t['buffer'] }.compact).to eq(
          %w(buffer_1 buffer_1 buffer_2 buffer_2 buffer_3 buffer_3 buffer_4 buffer_4
             buffer_5 buffer_5))
      end
    end

    describe 'maximizes concurrency with buffers' do
      let(:profile_scheme){ ProfileSchemeTestHelper.minimized_technology_distribution_buffers }

      it 'maximizes concurrency with buffers' do
        expect(new_profile.values.flatten.count).to eq(3)
      end
    end
  end
end

