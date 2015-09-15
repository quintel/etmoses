require 'rails_helper'

RSpec.describe TestingGroundsController do
  let(:user){ FactoryGirl.create(:user) }

  it "visits the import path" do
    user = FactoryGirl.create(:user)
    sign_in(user)

    get :import

    expect(response.status).to eq(200)
  end

  describe "#perform_import" do
    let(:user){ FactoryGirl.create(:user) }
    let!(:topology){ FactoryGirl.create(:topology, name: "Default topology")}
    let!(:technology){ FactoryGirl.create(:importable_technology,
                        key: "magical_technology") }

    before do
      sign_in(user)

      stub_et_engine_request
      stub_scenario_request

      expect_any_instance_of(Import).to receive(:buildings).twice.and_return([])

      post :perform_import, import: { scenario_id: 1, market_model_id: 5 }
    end

    it "renders the new template after performs an import" do
      expect(response).to render_template(:new)
    end

    it "assigns a market model id to the testing ground" do
      expect(assigns(:testing_ground).market_model_id).to eq(5)
    end
  end

  describe "#calculate_concurrency" do
    let(:topology){ FactoryGirl.create(:topology) }

    describe "maximum profile differentiation" do
      it "combines a testing ground topology with a set of technologies" do
        sign_in(user)

        post :calculate_concurrency,
              technology_distribution: profile_json,
              topology_id: topology.id,
              format: :js

        result = controller.instance_variable_get("@testing_ground_profile").as_json

        expect(result.values.flatten.count).to eq(2)
        expect(result.keys.count).to eq(2)
      end
    end

    describe "minimum profile differentiation" do
      it "combines a testing ground topology with a set of technologies and no profiles" do
        sign_in(user)

        post :calculate_concurrency,
              technology_distribution: profile_json,
              topology_id: topology.id,
              format: :js

        result = controller.instance_variable_get("@testing_ground_profile").as_json

        expect(result.values.flatten.count).to eq(2)
        expect(result.keys.count).to eq(2)
      end

      it "combines a testing ground topology with a set of technologies and the same amount of profiles as technologies" do
        5.times{ FactoryGirl.create(:technology_profile,
                    technology: 'households_solar_pv_solar_radiation') }

        5.times{ FactoryGirl.create(:technology_profile,
                    technology: 'transport_car_using_electricity') }

        tech_distribution = JSON.parse(profile_json).map do |t|
          t.update('concurrency' => 'min')
        end

        sign_in(user)

        post :calculate_concurrency,
              technology_distribution: JSON.dump(tech_distribution),
              topology_id: topology.id,
              format: :js

        result = controller.instance_variable_get("@testing_ground_profile").as_json

        expect(result.values.flatten.map{|t| t[:profile]}.uniq.length).to eq(10)
      end

      it "combines a testing ground topology with a set of technologies with less profiles than technologies" do
        2.times{ FactoryGirl.create(:technology_profile,
                  technology: 'transport_car_using_electricity') }

        sign_in(user)

        tech_distribution = JSON.parse(profile_json).map do |t|
          t.update('concurrency' => 'min')
        end

        post :calculate_concurrency,
              technology_distribution: JSON.dump(tech_distribution),
              topology_id: topology.id,
              format: :js

        result = controller.instance_variable_get("@testing_ground_profile").as_json

        expect(result.values.flatten.map{|t| t[:profile]}.uniq.length).to eq(3)
        expect(result.values.flatten.length).to eq(6)
      end
    end
  end

  describe "#create" do
    let(:topology){ FactoryGirl.create(:topology) }
    let(:market_model) { FactoryGirl.create(:market_model) }
    it "creates a testing ground" do
      sign_in(user)

      expect_any_instance_of(TestingGround).to receive(:valid?).and_return(true)
      post :create, TestingGroundsControllerTest.create_hash(topology.id, market_model.id)

      expect(TestingGround.count).to eq(1)
    end

    it "redirects to show page" do
      sign_in(user)

      expect_any_instance_of(TestingGround).to receive(:valid?).and_return(true)
      post :create, TestingGroundsControllerTest.create_hash(topology.id, market_model.id)

      expect(response).to redirect_to(testing_ground_path(TestingGround.last))
    end

    it "assings the testing ground to the current user" do
      sign_in(user)

      expect_any_instance_of(TestingGround).to receive(:valid?).and_return(true)
      post :create, TestingGroundsControllerTest.create_hash(topology.id, market_model.id)

      expect(TestingGround.last.user).to eq(controller.current_user)
    end
  end

  describe "#data.json" do
    let!(:sign_in_user){ sign_in(user) }

    it "shows the data of a testing ground" do
      testing_ground = FactoryGirl.create(:testing_ground, technology_profile: {})

      get :data, format: :json, id: testing_ground.id

      expect(response.status).to eq(200)
    end

    it "denies permission for the data of a private testing grounds" do
      testing_ground = FactoryGirl.create(:testing_ground, public: false)

      get :data, format: :json, id: testing_ground.id

      expect(response.status).to eq(403)
    end

  end

  describe "#show" do
    it "shows a testing ground" do
      sign_in(user)

      testing_ground = FactoryGirl.create(:testing_ground)

      get :show, id: testing_ground.id

      expect(response.status).to eq(200)
    end

    it "doesn't show a testing ground when it's private" do
      sign_in(user)

      testing_ground = FactoryGirl.create(:testing_ground, public: false)

      get :show, id: testing_ground.id

      expect(response).to redirect_to(root_path)
    end

    it "shows a testing ground when it's private" do
      sign_in(user)

      testing_ground = FactoryGirl.create(:testing_ground,
                                          user: user, public: false)

      get :show, id: testing_ground.id

      expect(response.status).to eq(200)
    end
  end

  describe "#export" do
    it "visits export path" do
      sign_in(user)

      testing_ground = FactoryGirl.create(:testing_ground)

      get :export, id: testing_ground.id

      expect(response.status).to eq(200)
    end
  end

  describe "#technology_profile" do
    it "exports csv file" do
      sign_in(user)

      testing_ground = FactoryGirl.create(:testing_ground,
                                           technology_profile: {"lv1" => []})

      get :technology_profile, id: testing_ground.id, format: :csv

      expect(response.status).to eq(200)
    end
  end

  describe "#edit" do
    it "visits edit path of owned testing ground" do
      sign_in(user)

      testing_ground = FactoryGirl.create(:testing_ground,
                                           user: user,
                                           technology_profile: {"lv1" => []})

      get :edit, id: testing_ground.id

      expect(response.status).to eq(200)
    end

    it "visits edit path of another users testing ground" do
      sign_in(user)

      testing_ground = FactoryGirl.create(:testing_ground,
                                           technology_profile: {"lv1" => []})

      get :edit, id: testing_ground.id

      expect(response).to redirect_to(root_path)
    end

    it "doesn't show the edit page of a testing ground when it's private" do
      sign_in(user)

      testing_ground = FactoryGirl.create(:testing_ground, public: false)

      get :edit, id: testing_ground.id

      expect(response).to redirect_to(root_path)
    end

    it "shows the edit page of a testing ground when it's private" do
      sign_in(user)

      testing_ground = FactoryGirl.create(:testing_ground,
                                          user: user, public: false)

      get :edit, id: testing_ground.id

      expect(response.status).to eq(200)
    end
  end

  describe "#update" do
    let(:topology){
      FactoryGirl.create(:large_topology)
    }

    let(:testing_ground){
      FactoryGirl.create(:testing_ground, name: "Hello world",
                                          user: user,
                                          topology: topology,
                                          technology_profile: {"lv1" => []}) }

    let(:private_testing_ground){
      testing_ground.update_attributes(public: false, user_id: 999999)
      testing_ground
    }

    let(:update_hash){
      TestingGroundsControllerTest.update_hash
    }

    it "updates testing ground" do
      sign_in(user)

      patch :update, id: testing_ground.id,
                   testing_ground: update_hash

      expect(testing_ground.reload.name).to eq("2015-08-02 - Test123")
    end

    it "doesn't update a private testing ground" do
      sign_in(user)

      patch :update, id: private_testing_ground.id,
                   testing_ground: update_hash

      expect(response).to redirect_to(root_path)
    end

    it "updates testing ground with a csv" do
      sign_in(user)

      patch :update, id: testing_ground.id,
        testing_ground: update_hash.merge({
          technology_profile_csv: fixture_file_upload("technology_profile.csv",
                                                      "text/csv")
        })

      expect(testing_ground.reload.technology_profile["lv1"][0].profile).to eq("solar_tv_zwolle")
    end
  end

  describe "#save_as" do
    let!(:sign_in_user){ sign_in(user) }
    let(:testing_ground){ FactoryGirl.create(:testing_ground, user: user) }

    it "clones an existing testing ground" do
      post :save_as, id: testing_ground.id, testing_ground: { name: "Test" }

      expect(response).to redirect_to(testing_ground_path(TestingGround.last))
    end

    it "counts 2 testing grounds" do
      post :save_as, id: testing_ground.id, testing_ground: { name: "Test" }

      expect(TestingGround.count).to eq(2)
    end

    it "saves as a new name" do
      post :save_as, id: testing_ground.id, testing_ground: { name: "New name" }

      expect(TestingGround.last.name).to eq("New name")
    end
  end

  describe "#store strategies" do
    let(:strategies){ {
      "solar_storage"=>false,
      "battery_storage"=>false,
      "solar_power_to_heat"=>false,
      "solar_power_to_gas"=>false,
      "buffering_electric_car"=>false,
      "buffering_space_heating"=>false,
      "postponing_base_load"=>false,
      "saving_base_load"=>false,
      "capping_solar_pv"=>false,
      "capping_fraction"=>1.0
    } }

    let!(:sign_in_user){ sign_in(user) }
    let(:testing_ground){ FactoryGirl.create(:testing_ground, user: user) }

    it "saves strategies" do
      post :store_strategies, id: testing_ground.id, format: :js, strategies: strategies

      expect(JSON.parse(testing_ground.selected_strategy.to_json)).to eq(strategies)
    end
  end
end
