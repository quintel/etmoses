require 'rails_helper'

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
          testing_ground_technologies_without_profiles, topology
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
end

