require 'rails_helper'

RSpec.describe TestingGround::Concurrency do
  let(:calculation) {
    TestingGround::Concurrency.new(JSON.dump(profile)).concurrensize
  }

  let(:technologies) { calculation.list.values.flatten }

  describe 'empty profile' do
    let(:profile) { [] }

    it 'returns a TechnologyList' do
      expect(calculation.class).to eq(TechnologyList)
    end
  end

  # LES:
  #
  # Endpoint 1
  # -> EV |  1 unit
  describe 'one technology to one endpoint' do
    let(:profile) {
      TechnologyDistributorData.load_concurrency_file("ev_basic")
    }

    let!(:technology_profiles){
      5.times do
        FactoryGirl.create(:technology_profile,
                            technology: "transport_car_using_electricity")
      end
    }

    it 'concurrensizes to the correct amount of units' do
      expect(technologies.size).to eq(5)
    end

    it 'concurrensizes correctly to the profiles' do
      expect(technologies.map(&:profile).size).to eq(5)
    end
  end

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

    describe "solar panel technology to two endpoints" do
      # LES:
      #
      # Endpoint 1
      # -> Solar Panel | 1 unit
      # Endpoint 2
      # -> Solar Panel | 1 unit

      let(:profile) {
        TechnologyDistributorData.load_file('solar_pv_distribution_two_nodes_lv1_and_lv2')
      }

      it 'minimizes concurrency correctly for profiles' do
        expect(technologies.map(&:profile).uniq.count).to eq(2)
      end
    end

    describe "maximizes concurrency with one technology to one node of a multi-node topology" do
      # LES:
      #
      # Endpoint 1
      # -> Solar Panel | 2 units

      let(:profile){
        TechnologyDistributorData.load_file('solar_pv_nodes_maximize_lv1')
      }

      it "expects only one profile" do
        expect(technologies.map(&:profile).uniq.count).to eq(1)
      end

      it "expects only one technology" do
        expect(technologies.count).to eq(1)
      end
    end

    describe "maximizes concurrency" do
      # LES:
      #
      # Endpoint 1
      # -> Solar Panel | 1 unit | Zwolle  | max
      # -> Solar Panel | 1 unit | Ameland | max
      #
      # Endpoint 2
      # -> Solar Panel | 1 unit | Zwolle  | max
      # -> Solar Panel | 1 unit | Ameland | max
      #
      let(:profile){
        TechnologyDistributorData.load_file('solar_pv_distribution_minimized_concurrency_two_nodes_lv1_and_lv2')
      }

      it "expects only one profile" do
        expect(technologies.map(&:profile).uniq.count).to eq(1)
      end

      it "expects no duplicate entries per node" do
        expect(technologies.length).to eq(2)
      end

      it "counts the correct units" do
        expect(technologies.map(&:units)).to eq([2,2])
      end

      it "doesn't automatically fill in the demand" do
        expect(technologies.map{|t| t['demand'] }).to eq([nil, nil])
      end
    end

    # LES:
    #
    # Endpoint 1
    # -> Solar Panel | 7 units  | zwolle          | max
    # -> EV          | 32 units | ev_profile_11.3 | min
    #
    # Endpoint 2
    # -> Solar Panel | 7 units  | zwolle          | max
    # -> EV          | 32 units | ev_profile_11.3 | min
    #
    # (5 profiles for EV * 2) + (1 profile for PV * 2) = 12 profiles in total
    describe "minimizes concurrency with a subset of technologies" do
      let(:profile){
        TechnologyDistributorData.load_file('solar_pv_and_ev_distribution_two_nodes_lv1_and_lv2')
      }

      it "expects only the electric car to have minimum concurrency" do
        expect(technologies.length).to eq(12)
      end
    end

    # LES:
    #
    # Endpoint 1
    # -> base_load_edsn | 31 units | min
    #
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
        let(:profile){
          distribution = TechnologyDistributorData.load_file('base_load_edsn')
          distribution[0]["units"] = 31.0
          distribution
        }

        it 'expects only EDSN profiles' do
          load_profile_id = technologies.first["profile"]

          expect(LoadProfile.find(load_profile_id).key).to eq("edsn_1")
        end

        it "doesn't minimize" do
          expect(technologies.length).to eq(1)
        end
      end

      describe "minimizes concurrency only with non-EDSN profiles" do
        let(:profile){
          distribution = TechnologyDistributorData.load_file('base_load')
          distribution[0]["units"] = 9.0
          distribution
        }

        it 'only makes use of non-EDSN profiles' do
          load_profile_id = technologies.first["profile"]

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

    # LES:
    #
    # Endpoint lv2
    # -> buffer_1
    #    -> space_heater_air
    #    -> space_heater_ground
    # -> solar_pv
    #
    describe 'minimizes concurrency with buffers' do
      let(:profile){
        TechnologyDistributorData.load_file('space_heater_buffers_two_nodes_lv1_and_lv2')
      }

      it 'creates 5 buffers' do
        expect(technologies.map(&:composite_value).compact).to eq([
          "buffer_space_heating_1",
          "buffer_space_heating_2",
          "buffer_space_heating_3",
          "buffer_space_heating_4",
          "buffer_space_heating_5"
        ])
      end

      it 'minimizes concurrency with buffers' do
        expect(technologies
               .map(&:associates).flatten
               .map(&:buffer)).to eq([
          "buffer_space_heating_1", "buffer_space_heating_1",
          "buffer_space_heating_2", "buffer_space_heating_2",
          "buffer_space_heating_3", "buffer_space_heating_3",
          "buffer_space_heating_4", "buffer_space_heating_4",
          "buffer_space_heating_5", "buffer_space_heating_5"
        ])
      end
    end

    # LES:
    #
    # lv1
    # -> Buffer 1
    #    space_heater_ground_water
    #    space_heater_air_water
    # -> Buffer 2
    #    space_heater_ground_water
    #    space_heater_air_water
    #
    describe 'maximizes concurrency with buffers' do
      let(:profile){
        TechnologyDistributorData.load_file('space_heater_buffers_minimized_concurrency')
      }

      it '1 buffer remains' do
        expect(technologies.count).to eq(1)
      end

      it 'contains 2 associates' do
        expect(technologies.map(&:associates).flatten.count).to eq(2)
      end

      it 'counts the correct amount of buffers' do
        expect(technologies.last.units).to eq(4)
      end

      it 'counts the correct amount of associates' do
        expect(technologies.last.associates.map(&:units)).to eq([2,2])
      end
    end

    # LES:
    #
    # lv1
    # -> Buffer 1
    #    space_heater_ground_water
    # -> Solar PV
    # lv2
    # -> Buffer 1
    #    space_heater_ground_water
    #
    describe 'minimize concurrency solar pv with buffers' do
      let!(:technology_profiles){
        5.times do |i|
          FactoryGirl.create(:technology_profile,
                              technology: "households_solar_pv_solar_radiation")
        end
      }

      let(:profile){
        TechnologyDistributorData.load_file('solar_pv_minimize_concurrency_with_buffers')
      }

      it '2 buffer remain + 5 solar PV' do
        expect(technologies.count).to eq(7)
      end

      it 'contains 2 associates in total' do
        expect(technologies.map(&:associates).flatten.count).to eq(2)
      end

      it 'holds the original buffer names' do
        expect(technologies.select(&:composite).map(&:composite_value)).to eq([
          "buffer_space_heating_1", "buffer_space_heating_1"
        ])
      end
    end
  end
end
