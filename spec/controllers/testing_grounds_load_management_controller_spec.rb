require 'rails_helper'

#
# Separate tests for load management issues
#

RSpec.describe TestingGroundsController do
  let(:user){ FactoryGirl.create(:user) }

  let!(:sign_in_user) { sign_in(:user, user) }

  let(:topology_graph){ FakeLoadManagement.topology_graph }

  let(:topology){ FactoryGirl.create(:topology, graph: topology_graph) }

  let(:testing_ground){
    FactoryGirl.create(:testing_ground, technology_profile: technology_profile,
                                        topology: topology)
  }

  # Testing of the buffering of local PV excess in heat pumps
  #
  describe "testing of buffering of local pv excess in heat pumps" do
    let(:solar_load_profile){ FactoryGirl.create(:load_profile, key: 'solar_pv_test') }
    let(:heat_pump_load_profile){
      FactoryGirl.create(:load_profile, key: 'heat_pump_test')
    }

    let!(:load_profiles){
      curves = [
        Network::Curve.new([-1.5, -1.5, -1.5, -1.5, 0,    0]),
        Network::Curve.new([   0,    0,    0,    0, 10.0, 0])
      ]

      allow_any_instance_of(Calculation::TechnologyLoad).to receive(:profile_for)
        .and_return(*curves)

      FactoryGirl.create(:load_profile_component,
                         curve_type: 'default', load_profile: solar_load_profile)

      FactoryGirl.create(:load_profile_component,
                         curve_type: 'default', load_profile: heat_pump_load_profile)

    }

    let(:technology_profile){
      {
        "CONGESTED_END_POINT_1" => [{
          "name"        => "Solar PV",
          "type"        => "households_solar_pv_solar_radiation",
          "behavior"    => nil,
          "profile"     => solar_load_profile.id,
          "load"        => nil,
          "capacity"    => -1.5,
          "demand"      => nil,
          "volume"      => nil,
          "units"       => 1,
          "concurrency" => "max"
        },
        {
          "name"        => "Heat pump",
          "type"        => "households_space_heater_heatpump_air_water_electricity",
          "behavior"    => nil,
          "profile"     => heat_pump_load_profile.id,
          "load"        => nil,
          "capacity"    => 3.0,
          "demand"      => nil,
          "volume"      => nil,
          "units"       => 1,
          "concurrency" => "max"
        }]
      }
    }

    describe "#buffering_heat_pumps" do
      it "no strategy applied" do
        get :data, format: :json, id: testing_ground.id,
                  strategies: FakeLoadManagement.strategies

        expect(JSON.parse(response.body)["graph"]["load"].reject{|t| t.zero?}).to eq([
          -1.5, -1.5, -1.5, -1.5, 10
        ])
      end

      it "buffering heat pumps strategy applied" do
        get :data, format: :json, id: testing_ground.id,
                  strategies: FakeLoadManagement.strategies(buffering_space_heating: true)

        expect(JSON.parse(response.body)["graph"]["load"].reject{|t| t.zero? }).to eq(
          [1.0] * 16
        )
      end
    end
  end

  # Testing of the postponing of base load
  # with anonimous base load profile
  describe "applying postponing of base load" do
    let(:load_profile){
      FactoryGirl.create(:load_profile, key: 'edsn_inflex_and_flex_parts')
    }
    let!(:load_profiles){
      FactoryGirl.create(:load_profile_component, curve_type: 'flex', load_profile: load_profile)
      FactoryGirl.create(:load_profile_component, curve_type: 'inflex', load_profile: load_profile)

      expect_any_instance_of(InstalledTechnology).to receive(:profile_curves)
        .at_least(1).times.and_return({
          flex:   Network::Curve.new(flex_curve),
          inflex: Network::Curve.new(inflex_curve)
        })
    }

    let(:technology_profile){
      {
        "CONGESTED_END_POINT_1"=> [{
          "name"        => "Buildings",
          "type"        => "base_load",
          "behavior"    => nil,
          "profile"     => load_profile.id,
          "load"        => nil,
          "capacity"    => nil,
          "demand"      => 2,
          "volume"      => nil,
          "units"       => 1,
          "concurrency" => "max"
        }]
      }
    }

    describe "with no possibility to fix the problem within 12 frames" do
      let(:flex_curve){   [0.2, [0.0] * 14].flatten }
      let(:inflex_curve){ [1.0] * 15 }

      it "applies no postponing of base load - just returns the load profile" do
        get :data, format: :json, id: testing_ground.id,
                  strategies: FakeLoadManagement.strategies

        expect(JSON.parse(response.body)["graph"]["load"]).to eq([
          1.2, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
          1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0
        ])
      end

      it "applies postponing of base load" do
        get :data, format: :json, id: testing_ground.id,
                  strategies: FakeLoadManagement.strategies(postponing_base_load: true)

        expect(JSON.parse(response.body)["graph"]["load"]).to eq([
          1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
          1.0, 1.0, 1.0, 1.0, 1.2, 1.0, 1.0
        ])
      end
    end
  end

  # Testing of the postponing of base load
  # with edsn profiles it shouldn't change
  #
  describe "applying postponing of base load" do
    let!(:load_profiles){
      load_profile = FactoryGirl.create(:load_profile, key: 'edsn_inflex_and_flex_parts')
      FactoryGirl.create(:load_profile_component, curve_type: 'flex', load_profile: load_profile)
      FactoryGirl.create(:load_profile_component, curve_type: 'inflex', load_profile: load_profile)

      expect_any_instance_of(InstalledTechnology).to receive(:profile_curves)
        .at_least(1).times.and_return({
          flex:   Network::Curve.new(flex_curve),
          inflex: Network::Curve.new(inflex_curve)
        })
    }

    let(:technology_profile){
      {
        "CONGESTED_END_POINT_1"=> [{
          "name"        => "Buildings",
          "type"        => "base_load",
          "behavior"    => nil,
          "profile"     => "edsn_inflex_and_flex_parts",
          "load"        => nil,
          "capacity"    => nil,
          "demand"      => 2,
          "volume"      => nil,
          "units"       => 1,
          "concurrency" => "max"
        }]
      }
    }

    describe "with no possibility to fix the problem within 12 frames" do
      let(:flex_curve){   [0.2, [0.0] * 14].flatten }
      let(:inflex_curve){ [1.0] * 15 }

      it "applies no postponing of base load" do
        get :data, format: :json, id: testing_ground.id,
                  strategies: FakeLoadManagement.strategies(postponing_base_load: true)

        expect(JSON.parse(response.body)["graph"]["load"]).to eq([
          1.2, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
          1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0
        ])
      end
    end
  end

  #
  # Testing of the saving of the base load strategy
  # - Using one congested node in the topology
  #
  describe "applying saving of base load strategy" do
    let(:load_profile){
      FactoryGirl.create(:load_profile, key: 'edsn_inflex_and_flex_parts')
    }
    let!(:load_profiles){
      FactoryGirl.create(:load_profile_component, curve_type: 'flex', load_profile: load_profile)
      FactoryGirl.create(:load_profile_component, curve_type: 'inflex', load_profile: load_profile)

      expect_any_instance_of(InstalledTechnology).to receive(:profile_curves)
        .at_least(1).times.and_return({
          flex:   Network::Curve.new([0.1, 0.2, 0.3]),
          inflex: Network::Curve.new([0.9, 1.8, 2.7])
        })
    }

    let(:technology_profile){
      {
        "CONGESTED_END_POINT_1"=> [{
          "name"        => "Buildings",
          "type"        => "base_load_buildings",
          "behavior"    => nil,
          "profile"     => load_profile.id,
          "load"        => nil,
          "capacity"    => nil,
          "demand"      => 2,
          "volume"      => nil,
          "units"       => 1,
          "concurrency" => "max"
        }]
      }
    }

    it "applies no saving of base load - just returns the load profile" do
      get :data, format: :json, id: testing_ground.id,
                 strategies: FakeLoadManagement.strategies

      expect(JSON.parse(response.body)["graph"]["load"]).to eq([1.0, 2.0, 3.0])
    end

    it "applies saving of base load (i.e. shaving of the flex profile)" do
      get :data, format: :json, id: testing_ground.id,
                 strategies: FakeLoadManagement.strategies(saving_base_load: true)

      expect(JSON.parse(response.body)["graph"]["load"]).to eq([1.0, 1.8, 2.7])
    end
  end
end
