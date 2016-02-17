require 'rails_helper'

RSpec.describe TestingGroundsController do
  let(:user){ FactoryGirl.create(:user) }

  describe "#calculate_concurrency" do
    let(:topology){ FactoryGirl.create(:topology) }
    let(:technology_distribution_data) {
      TechnologyDistributorData.load_file('solar_pv_and_ev_distribution_two_nodes_lv1_and_lv2').to_json
    }

    let!(:sign_in_user) { sign_in(user) }

    describe "maximum profile differentiation" do
      let(:technology_distribution_data_max) {
        TechnologyDistributorData.load_file('solar_pv_max_node_lv1').to_json
      }

      it "expects the technologies not to be distributed among the nodes" do
        post :calculate_concurrency,
              technology_distribution: technology_distribution_data_max,
              topology_id: topology.id,
              format: :js

        result = controller.instance_variable_get("@testing_ground_profile").as_json

        expect(result.values.flatten.count).to eq(1)
      end

      it "combines a testing ground topology with a set of technologies" do
        post :calculate_concurrency,
              technology_distribution: technology_distribution_data,
              topology_id: topology.id,
              format: :js

        result = controller.instance_variable_get("@testing_ground_profile").as_json

        expect(result.values.flatten.count).to eq(4)
        expect(result.keys.count).to eq(2)
      end
    end

    # When minimizing the concurrency the technologies are not allowed
    # to jump between nodes. The node they are attached to should stay the
    # same.
    describe "minimum profile differentiation - testing node stickyness" do
      let(:technology_distribution_data_min) {
        TechnologyDistributorData.load_file('solar_pv_lv1_and_ev_lv2').to_json
      }

      let!(:perform_post) {
        post :calculate_concurrency,
              technology_distribution: technology_distribution_data_min,
              topology_id: topology.id,
              format: :js
      }

      it "expects the results for lv1 to not include transport_car_using_electricity" do
        result = controller.instance_variable_get("@testing_ground_profile").as_json

        expect(result["lv1"].map{|t| t[:type] }).to_not include('transport_car_using_electricity')
      end
    end

    describe "minimum profile differentiation" do
      it "combines a testing ground topology with a set of technologies and no profiles" do
        post :calculate_concurrency,
              technology_distribution: technology_distribution_data,
              topology_id: topology.id,
              format: :js

        result = controller.instance_variable_get("@testing_ground_profile").as_json

        expect(result.values.flatten.count).to eq(4)
        expect(result.keys.count).to eq(2)
      end

      describe "with 5 solar PV profiles and 5 electric car profiles" do
        let!(:create_profiles) {
          5.times{ FactoryGirl.create(:technology_profile,
                      technology: 'households_solar_pv_solar_radiation') }

          5.times{ FactoryGirl.create(:technology_profile,
                      technology: 'transport_car_using_electricity') }
        }

        let(:technology_distribution_data_min) {
          JSON.parse(technology_distribution_data).map do |t|
            t.update('concurrency' => 'min')
          end
        }

        it "combines a testing ground topology with a set of technologies and the same amount of profiles as technologies" do
          post :calculate_concurrency,
                technology_distribution: JSON.dump(technology_distribution_data_min),
                topology_id: topology.id,
                format: :js

          result = controller.instance_variable_get("@testing_ground_profile").as_json

          expect(result.values.flatten.map{|t| t[:profile]}.uniq.length).to eq(10)
        end
      end

      describe "less profiles than technologies" do
        let!(:create_profiles) {
          2.times{ FactoryGirl.create(:technology_profile,
                    technology: 'transport_car_using_electricity') }
        }

        let(:technology_distribution_data_min) {
          JSON.parse(technology_distribution_data).map do |t|
            t.update('concurrency' => 'min')
          end
        }

        it "combines a testing ground topology with a set of technologies with less profiles than technologies" do
          post :calculate_concurrency,
                technology_distribution: JSON.dump(technology_distribution_data_min),
                topology_id: topology.id,
                format: :js

          result = controller.instance_variable_get("@testing_ground_profile").as_json

          expect(result.values.flatten.map{|t| t[:profile]}.uniq.length).to eq(3)
          expect(result.values.flatten.length).to eq(6)
        end
      end
    end
  end
end
