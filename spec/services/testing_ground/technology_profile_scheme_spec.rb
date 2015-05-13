require 'rails_helper'

RSpec.describe TestingGround::TechnologyProfileScheme do
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
        TestingGround::TechnologyProfileScheme.new(
          testing_ground_technologies_without_profiles, topology
        ).build
      }

      it 'assigns the correct profiles' do
        expect(testing_ground_topology.values.flatten.map{|t|
          t['profile']}.compact.uniq.count).to eq(1)
      end

      it "spreads the units correctly" do
        expect(testing_ground_topology.values.flatten.size).to eq(12)
      end

      it "sets the units correctly" do
        expect(testing_ground_topology.values.flatten.map{|t|
          t['units'].to_i }.sum).to eq(210)
      end
    end

    describe "small topology" do
      let(:new_profile){ TestingGround::TechnologyProfileScheme.new(
                           basic_technologies, topology, "max"
                         ).build
      }

      it 'selects the least diverse amount of profiles' do
        expect(new_profile.values.flatten.map{|t|
          t['profile'] }.uniq.count).to eq(1)
      end

      it "counts the units correctly" do
        expect(new_profile.values.flatten.map{|t|
          t['units'] }).to eq([1,1])
      end
    end

    describe "big topology" do
      let(:new_profile){ TestingGround::TechnologyProfileScheme.new(
                           basic_technologies, large_topology, "max"
                         ).build
      }

      it 'selects the most diverse amount of profiles' do
        expect(new_profile.values.flatten.compact.map{|t|
          t['profile'] }.uniq.count).to eq(1)
      end

      it "counts the units correctly" do
        expect(new_profile.values.flatten.compact.map{|t|
          t['units'] }).to eq([1,1])
      end
    end

    describe "10 solar panels" do
      let(:new_profile){ TestingGround::TechnologyProfileScheme.new(
                           basic_technologies("10.0"), topology, "max"
                         ).build
      }

      it "divides the technologies correctly" do
        expect(new_profile.values.flatten.map{|t| t['units']}.sum).to eq(10)
      end

      it 'selects the least diverse amount of profiles' do
        expect(new_profile.values.flatten.compact.map{|t|
          t['profile'] }.uniq.count).to eq(1)
      end
    end
  end

  # Minimum concurrency
  describe "minimum concurrency" do
    describe "small topology" do
      let(:new_profile){ TestingGround::TechnologyProfileScheme.new(
                           basic_technologies, topology, "min"
                         ).build
      }

      it 'selects the most diverse amount of profiles' do
        expect(new_profile.values.flatten.map{|t|
          t['profile'] }.count).to eq(2)
      end

      it "counts the units correctly" do
        expect(new_profile.values.flatten.map{|t|
          t['units'] }).to eq([1,1])
      end
    end

    describe "big topology" do
      let(:new_profile){ TestingGround::TechnologyProfileScheme.new(
                           basic_technologies, large_topology, "min"
                         ).build
      }

      it 'selects the most diverse amount of profiles' do
        expect(new_profile.values.flatten.compact.map{|t|
          t['profile'] }.uniq.count).to eq(2)
      end

      it "counts the units correctly" do
        expect(new_profile.values.flatten.compact.map{|t|
          t['units'] }).to eq([1,1])
      end
    end

    describe "10 solar panels" do
      let(:new_profile){ TestingGround::TechnologyProfileScheme.new(
                           basic_technologies("10.0"), topology, "min"
                         ).build
      }

      it "divides the technologies correctly" do
        expect(new_profile.values.flatten.map{|t| t['units']}.sum).to eq(10)
      end

      it 'selects the most diverse amount of profiles' do
        expect(new_profile.values.flatten.compact.map{|t|
          t['profile'] }.uniq.count).to eq(5)
      end
    end
  end
end
