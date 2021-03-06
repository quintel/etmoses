require 'rails_helper'

RSpec.describe BusinessCasesController do
  let(:user) { FactoryGirl.create(:user) }
  let!(:sign_in_user) { sign_in(user) }
  let(:market_model) { FactoryGirl.create(:market_model) }

  let(:testing_ground) {
    FactoryGirl.create(:testing_ground, user: user, market_model: market_model)
  }

  let(:testing_ground_without_mm) {
    FactoryGirl.create(:testing_ground, user: user)
  }

  describe "#update" do
    let(:business_case) {
      FactoryGirl.create(:business_case, testing_ground: testing_ground)
    }

    it 'updates the current business case' do
      put :update, testing_ground_id: testing_ground.id, id: business_case.id,
                   business_case: {
                     financials: JSON.dump([{row: 'customer', tariff: 123 }])
                   },
                   format: :js

      expect(business_case.reload.financials).to eq([{
        "row" => 'customer', "tariff" => 123
      }])
    end
  end

  describe "#show" do
    let(:business_case) {
      FactoryGirl.create(:business_case, testing_ground: testing_ground)
    }

    it "goes to the show page of a business case" do
      get :show, testing_ground_id: testing_ground.id, id: business_case.id

      expect(response).to be_success
    end
  end

  describe "illegal update" do
    let(:business_case) {
      FactoryGirl.create(:business_case)
    }

    it 'updates the current business case' do
      put :update, testing_ground_id: testing_ground.id, id: business_case.id,
                   business_case: {
                     financials: JSON.dump([{row: 'customer', tariff: 123 }])
                   }

      expect(response).to redirect_to(root_path)
    end
  end

  describe "#compare_with" do
    let(:comparing_testing_ground) {
      FactoryGirl.create(:testing_ground)
    }

    let(:business_case) {
      FactoryGirl.create(:business_case, testing_ground: testing_ground)
    }

    let!(:other_business_case) {
      FactoryGirl.create(:business_case, testing_ground: comparing_testing_ground)
    }

    it "visits compare path (to compare business cases) and failing" do
      get :compare_with, testing_ground_id: testing_ground.id, id: business_case.id

      expect(response.status).to eq(422)
    end

    it "visits compare path (to compare business cases)" do
      xhr :get, :compare_with, testing_ground_id: testing_ground.id,
                         comparing_testing_ground_id: comparing_testing_ground.id,
                         id: business_case.id,
                         format: :js

      expect(controller.instance_variable_get("@business_case_rows")).to_not be_blank
    end
  end

  describe "validate business case" do
    it "validates a business case" do
      topology_template = FactoryGirl.create(:topology_template)
      market_model_template = FactoryGirl.create(:market_model_template)

      post :validate, business_case: {
        topology_template_id: topology_template,
        market_model_template_id: market_model_template }

      expect(JSON.parse(response.body)).to eq({ "valid" => false })
    end
  end

  describe "render summary" do
    describe "all is fine" do
      let(:business_case) {
        FactoryGirl.create(:business_case, testing_ground: testing_ground)
      }

      it "gives a 200 OK" do
        post :render_summary,
          testing_ground_id: testing_ground.id,
          id: business_case.id,
          format: :js

        expect(response).to be_success
      end
    end

    describe "raises an error" do
      let(:business_case) {
        FactoryGirl.create(:business_case, testing_ground: testing_ground, financials: nil)
      }

      it "gives a 200 OK" do
        post :render_summary,
          testing_ground_id: testing_ground.id,
          id: business_case.id,
          format: :js

        expect(response).to be_success
      end
    end
  end
end
