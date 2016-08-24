require 'rails_helper'

include TechnologyDistributorData

RSpec.describe TestingGround::TechnologyDistributor do
  let(:topology){ FactoryGirl.build(:topology).graph }
  let(:large_topology){ FactoryGirl.build(:large_topology).graph }

  let!(:technology_profiles){
    5.times do
      FactoryGirl.create(:technology_profile,
                          technology: "households_solar_pv_solar_radiation")
    end
  }

  # Maximum concurrency
  describe "maximum concurrency" do
    describe "assiging the correct profiles" do
      let(:testing_ground_topology){
        TestingGround::TechnologyDistributor.new(
          TechnologyDistributorData.load_file('technologies_with_no_nodes_and_profiles'), topology
        ).build
      }

      it "spreads the units correctly" do
        expect(testing_ground_topology.size).to eq(12)
      end

      it "sets the units correctly" do
        expect(testing_ground_topology.map{|t|
          t['units'].to_i }.sum).to eq(18)
      end
    end

    describe "small topology" do
      let(:new_profile){ TestingGround::TechnologyDistributor.new(
                           basic_technologies, topology
                         ).build
      }

      it "counts the units correctly" do
        expect(new_profile.map{|t| t['units'] }).to eq([1,1])
      end
    end

    describe "big topology" do
      let(:new_profile){ TestingGround::TechnologyDistributor.new(
                           basic_technologies, large_topology
                         ).build
      }

      it "counts the units correctly" do
        expect(new_profile.compact.map{|t| t['units'] }).to eq([1,1])
      end
    end

    describe "10 solar panels" do
      let(:new_profile){ TestingGround::TechnologyDistributor.new(
                           basic_technologies("10.0"), topology
                         ).build
      }

      it "divides the technologies correctly" do
        expect(new_profile.map{|t| t['units']}.sum).to eq(10)
      end

      it 'selects the least diverse amount of profiles' do
        expect(new_profile.compact.map{|t|
          t['profile'] }.uniq.count).to eq(1)
      end
    end

    describe 'houses and buildings' do
      describe "less edge nodes than houses and buildings" do
        let(:new_profile){ TestingGround::TechnologyDistributor.new(
            [{ "name" => "Household", "type" => "base_load", "units" => 2 },
            { "name" => "Buildings", "type" => "base_load_buildings", "units" => 1 }],
            large_topology
          ).build
        }

        it "distributes houses and buildings as though they are one technology" do
          expect(new_profile.map{|t| t["node"] }.uniq).to eq(['lv1', 'lv2', 'lv3'])
        end
      end

      describe 'one building more than edge nodes' do
        let(:new_profile){ TestingGround::TechnologyDistributor.new(
            [{ "name" => "Household", "type" => "base_load", "units" => 3 },
            { "name" => "Buildings", "type" => "base_load_buildings", "units" => 3 }],
            large_topology
          ).build
        }

        it "distributes houses and buildings as though they are one technology" do
          expect(new_profile.map{|t| t["node"] }.uniq).to eq(['lv1', 'lv2', 'lv3'])
        end
      end
    end
  end

  # Minimum concurrency
  describe "minimum concurrency" do
    describe "small topology" do
      let(:new_profile){ TestingGround::TechnologyDistributor.new(
                           basic_technologies, topology
                         ).build
      }

      it "counts the units correctly" do
        expect(new_profile.map{|t| t['units'] }).to eq([1,1])
      end
    end

    describe "big topology" do
      let(:new_profile){ TestingGround::TechnologyDistributor.new(
                           basic_technologies, large_topology
                         ).build
      }

      it "counts the units correctly" do
        expect(new_profile.compact.map{|t| t['units'] }).to eq([1,1])
      end
    end

    describe "10 solar panels" do
      let(:new_profile){ TestingGround::TechnologyDistributor.new(
                           basic_technologies("10.0"), topology
                         ).build
      }

      it "divides the technologies correctly" do
        expect(new_profile.map{|t| t['units']}.sum).to eq(10)
      end
    end
  end

  # composites
  describe "setting composites over end points of a topology" do
    let(:composite_technologies) {
      [
        {
          "name"      => "Buffer space heating",
          "type"      => "buffer_space_heating",
          "capacity"  => "5.0",
          "units"     => "10.0",
          "composite" => true,
          "includes"  => [ "households_space_heater_heatpump_ground_water_electricity" ]
        },
        {
          "name"     => "Heat pump for space heating (ground)",
          "type"     => "households_space_heater_heatpump_ground_water_electricity",
          "capacity" => "2.0",
          "position_relative_to_buffer" => "boosting",
          "units"    => "10.0"
        }
      ]
    }

    let(:new_profile){
      TestingGround::TechnologyDistributor.new(composite_technologies, topology
      ).build
    }

    it "sets the composite values correctly" do
      expect(new_profile.map{|t| t['composite_value']}.compact).to eq([
        'buffer_space_heating_1', 'buffer_space_heating_2'
      ])
    end

    it "sets the buffer values correctly" do
      expect(new_profile.flat_map(&:associates).map(&:buffer)).to eq([
        'buffer_space_heating_1', 'buffer_space_heating_2'
      ])
    end
  end

  describe "realistic scenario" do
    let!(:profiles) {
      FactoryGirl.create(:technology_profile,
        technology: 'base_load')

      FactoryGirl.create(:technology_profile,
        technology: 'buffer_space_heating')

      FactoryGirl.create(:technology_profile,
        technology: 'buffer_water_heating')

      FactoryGirl.create(:technology_profile,
        technology: 'base_load_buildings')

      FactoryGirl.create(:technology_profile,
        technology: 'transport_car_using_electricity')
    }

    let(:technologies) {
      TechnologyDistributorData.load_file('technologies_scenario_515515')
    }

    let(:new_profile){
      TestingGround::TechnologyDistributor.new(technologies, topology).build
    }

    it "expects 24 buffers" do
      expect(new_profile.map(&:composite_value).compact.size).to eq(24)
    end

    it "expects all technologies to be valid" do
      expect(new_profile.all?(&:valid?)).to eq(true)
    end
  end
end
