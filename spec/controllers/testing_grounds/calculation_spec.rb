require 'rails_helper'

RSpec.describe TestingGroundsController do
  let(:user) { FactoryGirl.create(:user) }
  let!(:sign_in_user) { sign_in(user) }

  let(:load_profile) {
    FactoryGirl.create(:load_profile_with_curve)
  }

  let(:testing_ground) {
    FactoryGirl.create(:testing_ground, technology_profile: {
      'lv1' => [
        { name: "Generic technology",
          capacity: 1,
          profile: load_profile.id
        }
      ]
    })
  }

  let(:calculation_result) { JSON.parse(response.body)['networks'] }

  describe "calculating a LES - first week of january by default" do
    let!(:post_data) {
      post :data,
          format: :json, id: testing_ground.id,
          calculation: { range_start: 0, range_end: 672 }
    }

    it "has an electricity network present" do
      expect(calculation_result['electricity'].present?).to eq(true)
    end

    it "has a cropped size which defaults to the first week of january" do
      expect(calculation_result['electricity']['load'].size).to eq(673)
    end

    it "has a gas network" do
      expect(calculation_result['gas'].present?).to eq(true)
    end
  end

  describe "calculating a LES - custom range" do
    let!(:post_data) {
      post :data,
          format: :json, id: testing_ground.id,
          calculation: { range_start: 8064, range_end: 8736 }
    }

    it "has a cropped size which defaults to the first week of january" do
      expect(calculation_result['electricity']['load'].size).to eq(673)
    end

    it "calculates the first week of january in high resolution by default" do
      expect(calculation_result['gas']['load']).to eq([0.0] * 673)
    end
  end

  describe "calculating a LES from a static yml profile" do
    def get_profile(name)
      YAML.load(File.read("#{Rails.root}/spec/fixtures/data/technology_profiles/#{ name }.yml"))
    end

    #
    # Battery + other technology
    #
    describe "calculating a LES - first week of january for a battery and other technology" do
      let(:technology_profile) {
        profile = get_profile("battery_and_other")
        profile['lv1'][0][:profile] = { default: ([1.0] * 35040) }
        profile
      }

      let(:testing_ground) {
        FactoryGirl.create(:testing_ground, technology_profile: technology_profile)
      }

      let!(:post_data) {
        post :data, format: :json, id: testing_ground.id, calculation: {
          range_start: 0,
          range_end: 672,
          strategies: {
            "battery_storage"         => true,
            "ev_capacity_constrained" => false,
            "ev_excess_constrained"   => false,
            "ev_storage"              => false,
            "solar_power_to_heat"     => false,
            "solar_power_to_gas"      => false,
            "hp_capacity_constrained" => false,
            "hhp_switch_to_gas"       => false,
            "postponing_base_load"    => false,
            "saving_base_load"        => false,
            "capping_solar_pv"        => false,
            "capping_fraction"        => 1.0
          }
        }
      }

      it "charges the battery according to the correct volume" do
        expect(calculation_result['electricity']['load'][0..12]).to eq([
          0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.37400000000000055, -1.0
        ])
      end
    end

    #
    # Base load
    #
    describe "Base loads" do
      describe "calculating a LES - Base load" do
        let(:base_load_load_profile) {
          FactoryGirl.create(:load_profile_base_load)
        }

        let(:technology_profile) {
          profile = get_profile("base_load")
          profile['lv1'][0][:profile] = base_load_load_profile.id
          profile
        }

        let(:topology) {
          FactoryGirl.create(:topology_with_capacity)
        }

        let(:testing_ground) {
          FactoryGirl.create(:testing_ground,
            technology_profile: technology_profile,
            topology: topology)
        }

        let!(:post_data) {
          post :data, format: :json, id: testing_ground.id, calculation: {
            range_start: 0,
            range_end: 672,
            strategies: {
              "battery_storage"         => false,
              "ev_capacity_constrained" => false,
              "ev_excess_constrained"   => false,
              "ev_storage"              => false,
              "solar_power_to_heat"     => false,
              "solar_power_to_gas"      => false,
              "hp_capacity_constrained" => false,
              "hhp_switch_to_gas"       => false,
              "postponing_base_load"    => true,
              "saving_base_load"        => false,
              "capping_solar_pv"        => false,
              "capping_fraction"        => 1.0
            }
          }
        }

        it "skips 3 hours 12 quarters and time frames" do
          expect(calculation_result['electricity']['load'][0...12]).to eq(
            [ 0.35772357723577236, 0.35772357723577236, 0.35772357723577236,
              0.35772357723577236, 0.35772357723577236, 0.35772357723577236,
              0.35772357723577236, 0.35772357723577236, 0.35772357723577236,
              0.35772357723577236, 0.35772357723577236, 0.032520325203252036 ]
          )
        end

        it "the rest is 0" do
          expect(calculation_result['electricity']['load'][13..673]).to eq(
            [0.0] * 660
          )
        end
      end
    end
  end
end
