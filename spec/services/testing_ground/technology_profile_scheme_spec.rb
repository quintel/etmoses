require 'rails_helper'

RSpec.describe TestingGround::TechnologyProfileScheme do
  let(:topology){ FactoryGirl.build(:topology).graph.to_json }

  describe "minimal concurrency" do
    describe "assiging the correct profiles" do
      let!(:technology_profile){ FactoryGirl.create(:technology_profile,
                                  technology: "households_solar_pv_solar_radiation") }

      let(:testing_ground_topology){
        TestingGround::TechnologyProfileScheme.new({
          technologies: testing_ground_technologies_without_profiles.to_yaml,
          topology: topology,
          profile_differentiation: "min"
        }).build
      }

      it 'assigns the correct profiles' do
        expect(YAML::load(testing_ground_topology).values.flatten.map{|t| t['profile']}.uniq.count).to eq(2)
      end

      it "spreads the units correctly" do
        expect(YAML::load(testing_ground_topology).values.flatten.size).to eq(12)
      end
    end

    describe "maximum concurrency" do
      describe "assiging the correct profiles" do
        let!(:technology_profiles){
          5.times do
            FactoryGirl.create(:technology_profile,
                                    technology: "households_solar_pv_solar_radiation")
          end}

        let(:testing_ground_topology){
          TestingGround::TechnologyProfileScheme.new({
            technologies: testing_ground_technologies_without_profiles.to_yaml,
            topology: topology,
            profile_differentiation: "max"
          }).build
        }

        it 'assigns the correct profiles' do
          expect(YAML::load(testing_ground_topology).values.flatten.map{|t| t['profile']}.uniq.count).to eq(2)
        end

        it "spreads the units correctly" do
          expect(YAML::load(testing_ground_topology).values.flatten.size).to eq(12)
        end

        it "sets the units correctly" do
          expect(YAML::load(testing_ground_topology).values.flatten.map{|t|
            t['units'].to_i }.sum).to eq(210)
        end
      end
    end
  end
end
