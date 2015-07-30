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

  # Testing of the postponing of base load
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

    describe "with no possibility to fix the problem" do
      let(:flex_curve){   [0.2, [0.0] * 14].flatten }
      let(:inflex_curve){ [0.9] * 15 }

      it "applies no postponing of base load - just returns the load profile" do
        get :data, format: :json, id: testing_ground.id,
                  strategies: FakeLoadManagement.strategies

        expect(JSON.parse(response.body)["graph"]["load"]).to eq([
          1.1, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9
        ])
      end

      it "applies postponing of base load" do
        get :data, format: :json, id: testing_ground.id,
                  strategies: FakeLoadManagement.strategies(postponing_base_load: true)

        expect(JSON.parse(response.body)["graph"]["load"]).to eq([
          0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 1.1, 0.9, 0.9
        ])
      end
    end

    describe "with a possibility to fix the problem" do
      let(:flex_curve){   [0.2, [0.0] * 14].flatten }
      let(:inflex_curve){ [0.9, 0.9, 0.9, 0.6, [0.9] * 11].flatten }

      it "applies postponing of base load" do
        get :data, format: :json, id: testing_ground.id,
                  strategies: FakeLoadManagement.strategies(postponing_base_load: true)

        expect(JSON.parse(response.body)["graph"]["load"]).to eq([
          0.9, 0.9, 0.9, 0.8, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9
        ])
      end
    end

    describe "with no possibility to fix the problem at the end of the curve" do
      let(:flex_curve){   [[0.0] * 13, 0.2, 0.0].flatten }
      let(:inflex_curve){ [0.9] * 15 }

      it "applies postponing of base load, puts flex part at last frame" do
        get :data, format: :json, id: testing_ground.id,
                  strategies: FakeLoadManagement.strategies(postponing_base_load: true)

        expect(JSON.parse(response.body)["graph"]["load"]).to eq([
          0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9, 1.1
        ])
      end
    end
  end

  #
  # Testing of the saving of the base load strategy
  # - Using one congested node in the topology
  #
  describe "applying saving of base load strategy" do
    let!(:load_profiles){
      load_profile = FactoryGirl.create(:load_profile, key: 'edsn_inflex_and_flex_parts')
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
