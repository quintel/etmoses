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
    let!(:technology){ FactoryGirl.create(:technology,
                        key: "magical_technology",
                        import_from: "input_capacity") }

    it "renders the new template after performs an import" do
      sign_in(user)

      stub_et_engine_request
      stub_scenario_request

      post :perform_import, import: { scenario_id: 1 }

      expect(response).to render_template(:new)
    end
  end

  describe "#build_technology_toplogy" do
    let(:topology){ FactoryGirl.create(:topology) }

    describe "minimum profile differentiation" do
      it "combines a testing ground topology with a set of technologies" do
        sign_in(user)

        post :build_technology_toplogy,
              technologies: testing_ground_technologies_without_profiles_subset.to_yaml,
              topology: topology.graph,
              profile_differentiation: 'min'

        expect(YAML.load(response.body)).to eq({
          'lv1' => [{ "type"=>"households_solar_pv_solar_radiation",
                      "name"=>"Residential PV panel",
                      "units"=>2,
                      "capacity"=>1.5,
                      "profile"=> nil }],
          'lv2' => [{ "type"=>"households_solar_pv_solar_radiation",
                      "name"=>"Residential PV panel",
                      "units"=>2,
                      "capacity"=>1.5,
                      "profile"=> nil }]
        })
      end
    end

    describe "maximum profile differentiation" do
      it "combines a testing ground topology with a set of technologies and no profiles" do
        sign_in(user)

        post :build_technology_toplogy,
              technologies: testing_ground_technologies_without_profiles_subset.to_yaml,
              topology: topology.graph,
              profile_differentiation: 'max'

        expect(YAML.load(response.body).values.flatten.count).to eq(2)
        expect(YAML.load(response.body).keys.count).to eq(2)
      end

      it "combines a testing ground topology with a set of technologies and the same amount of profiles as technologies" do
        4.times{ FactoryGirl.create(:technology_profile,
                    technology: 'households_solar_pv_solar_radiation') }

        sign_in(user)

        post :build_technology_toplogy,
              technologies: testing_ground_technologies_without_profiles_subset.to_yaml,
              topology: topology.graph,
              profile_differentiation: 'max'

        expect(YAML.load(response.body).values.flatten.map{|t| t['profile']}.uniq.length).to eq(4)
      end

      it "combines a testing ground topology with a set of technologies with less profiles than technologies" do
        2.times{ FactoryGirl.create(:technology_profile,
                  technology: 'households_solar_pv_solar_radiation') }

        sign_in(user)

        post :build_technology_toplogy,
              technologies: testing_ground_technologies_without_profiles_subset.to_yaml,
              topology: topology.graph,
              profile_differentiation: 'max'


        expect(YAML.load(response.body).values.flatten.map{|t| t['profile']}.uniq.length).to eq(2)
        expect(YAML.load(response.body).values.flatten.length).to eq(4)
      end
    end
  end

  describe "#create" do
    it "creates a testing ground" do
      sign_in(user)

      expect_any_instance_of(TestingGround).to receive(:valid?).and_return(true)
      post :create, TestingGroundsControllerTest.create_hash

      expect(TestingGround.count).to eq(1)
    end

    it "redirects to show page" do
      sign_in(user)

      expect_any_instance_of(TestingGround).to receive(:valid?).and_return(true)
      post :create, TestingGroundsControllerTest.create_hash

      expect(response).to redirect_to(testing_ground_path(TestingGround.last))
    end
  end

  describe "#show.json" do
    it "shows the data of a testing ground" do
      sign_in(user)

      testing_ground = FactoryGirl.create(:testing_ground)

      get :show, format: :json, id: testing_ground.id

      expect(JSON.parse(response.body)).to eq(TestingGroundsControllerTest.show_hash)
    end
  end
end
