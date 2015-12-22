require 'rails_helper'

#
# Separate tests for load management issues
#

RSpec.describe TestingGround do
  let(:topology_graph){ FakeLoadManagement.topology_graph }

  let(:topology){ FactoryGirl.create(:topology, graph: topology_graph) }

  let(:testing_ground){
    FactoryGirl.create(:testing_ground, technology_profile: technology_profile,
                                        topology: topology)
  }

  def calculate(strategies = {})
    fake_strategies = FakeLoadManagement.strategies(strategies)
    GraphToTree.convert(testing_ground.to_calculated_graph(fake_strategies)).fetch(:load)
  end

  # Testing of the buffering of local PV excess in heat pumps
  #
  describe "testing of buffering of local pv excess in heat pumps" do
    let(:solar_load_profile){
      { 'default' => [-0.5] * 6 }
    }

    let(:heat_pump_load_profile){
      { 'default' => [0, 0, 0, 0, 0.5, 0] }
    }

    let(:technology_profile){
      {
        "CONGESTED_END_POINT_1" => [{
          "name"        => "Solar PV",
          "type"        => "households_solar_pv_solar_radiation",
          "behavior"    => nil,
          "profile"     => solar_load_profile,
          "load"        => nil,
          "capacity"    => -1.5,
          "demand"      => nil,
          "volume"      => nil,
          "units"       => 1,
          "concurrency" => "max"
        },
        {
          "name"            => "Buffer space heating #1",
          "type"            => "buffer_space_heating",
          "composite"       => true,
          "composite_value" => "buffer_space_heating_1",
          "behavior"        => nil,
          "profile"         => heat_pump_load_profile,
          "volume"          => 0.5,
          "units"           => 1,
          "concurrency"     => "max"
        },
        {
          "name"        => "Heat pump",
          "type"        => "households_space_heater_heatpump_air_water_electricity",
          "buffer"      => "buffer_space_heating_1",
          "behavior"    => nil,
          "profile"     => nil,
          "load"        => nil,
          "capacity"    => 1.0,
          "demand"      => nil,
          "volume"      => 0.5,
          "units"       => 1,
          "concurrency" => "max"
        }]
      }
    }

    describe "with quarterly data" do
      let!(:fake_lengths){
        allow_any_instance_of(Network::Curve).to receive(:frames_per_hour).and_return(4.0)
      }

      describe "#buffering_heat_pumps" do
        it "no strategy applied" do
          results = calculate

          expected = [
            0.0, 0.0, 0.0, 0.0,
            # 0.5 kWh used by the profile
            0.5,
            0.0
          ]

          expect(results.map do |val|
            # Adjust loads by solar production.
            val - solar_load_profile['default'].first
          end).to eq(expected)
        end

        it "buffering heat pumps strategy applied" do
          results = calculate(buffering_space_heating: true)

          expected = [
            # Buffering limited by capacity. 2x 1.0 kW = 0.5 kWh stored.
            1.0, 1.0,
            # Buffer is full.
            0.0, 0.0,
            # 0.5 kW is now subtracted from the buffer, and we can start
            # buffering again...
            0.5, 0.0
          ]

          expect(results.map do |val|
            # Adjust loads by solar production.
            val - solar_load_profile['default'].first
          end).to eq(expected)
        end
      end
    end

    describe "with hourly data" do
      let!(:fake_lengths){
        allow_any_instance_of(Network::Curve).to receive(:frames_per_hour).and_return(1.0)
      }

      describe "#buffering_heat_pumps" do
        it "no strategy applied" do
          results = calculate

          expected = [
            0.0, 0.0, 0.0, 0.0,
            # 0.5 kWh used by the use profile.
            0.5,
            0.0
          ]

          expect(results.map do |val|
            # Account for solar production.
            val.round(2) - solar_load_profile['default'].first
          end).to eq(expected)
        end

        it "buffering heat pumps strategy applied" do
          results = calculate(buffering_space_heating: true)

          expected = [
            # Buffer 0.5 kW in the first hour. This fills the buffers 0.5 kWh
            # volume.
            0.5,
            # Buffer is full...
            0.0, 0.0, 0.0,
            # 0.5 kWh used by the use profile, buffer refills.
            0.5,
            0.0
          ]

          expect(results.map do |val|
            # Account for solar production.
            val.round(2) - solar_load_profile['default'].first
          end).to eq(expected)
        end
      end
    end
  end

  # Testing of the postponing of base load
  #
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
        expect(calculate).to eq([
          1.2, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
          1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0
        ])
      end

      it "applies postponing of base load" do
        expect(calculate(postponing_base_load: true)).to eq([
          1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
          1.0, 1.0, 1.0, 1.0, 1.2, 1.0, 1.0
        ])
      end
    end

    describe "with a possibility to fix the problem" do
      let(:flex_curve){   [0.2, [0.0] * 16].flatten }
      let(:inflex_curve){ [1.0, 1.0, 1.0, 0.6, [1.0] * 13].flatten }

      it "applies postponing of base load" do
        expect(calculate(postponing_base_load: true)).to eq([
          1.0, 1.0, 1.0, 0.8, 1.0, 1.0, 1.0, 1.0, 1.0,
          1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0
        ])
      end
    end

    describe "with a possibility to fix the across multiple frames" do
      let(:flex_curve){   [0.2, [0.0] * 16].flatten }
      let(:inflex_curve){ [1.0, 1.0, 1.0, 0.9, 0.9, [0.0] * 12].flatten }

      it "applies postponing of base load" do
        expect(calculate(postponing_base_load: true)).to eq([
          1.0, 1.0, 1.0, 0.9, 0.9, 0.2, 0.0, 0.0, 0.0,
          0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
        ])
      end
    end

    describe "with no possibility to fix the problem before the end" do
      let(:flex_curve){   [0.2, [0.0] * 3].flatten }
      let(:inflex_curve){ [1.0] * 4 }

      it "applies postponing in the final frame" do
        expect(calculate(postponing_base_load: true)).to eq([
          1.0, 1.0, 1.0, 1.2
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
      expect(calculate).to eq([1.0, 2.0, 3.0])
    end

    it "applies saving of base load (i.e. shaving of the flex profile)" do
      old_strategies = FakeLoadManagement.strategies(solar_storage: true)
      testing_ground.selected_strategy.update_attributes(old_strategies)
      NetworkCache::Writer.from(testing_ground, old_strategies).write

      expect(calculate(saving_base_load: true)).to eq([1.0, 1.8, 2.7])
    end

    it "updates the saved strategies" do
      expect(calculate(saving_base_load: true)).to eq([1.0, 1.8, 2.7])
    end
  end
end
