require 'rails_helper'

RSpec.describe BusinessCasesController do
  let(:user){ FactoryGirl.create(:user) }
  let!(:sign_in_user){ sign_in(:user, user) }
  let(:testing_ground){ FactoryGirl.create(:testing_ground, user: user) }

  describe "#create" do
    let(:create_business_case){
      post :create, testing_ground_id: testing_ground.id
    }

    it 'creates a business case' do
      create_business_case

      expect(BusinessCase.count).to eq(1)
    end

    it "does not create an extra business case" do
      BusinessCase.create!(testing_ground: testing_ground)

      create_business_case

      expect(BusinessCase.count).to eq(1)
    end

    it "redirects to show page" do
      create_business_case

      expect(response).to redirect_to(
        testing_ground_business_case_path(testing_ground, BusinessCase.last))
    end
  end

  describe "#update" do
    let(:business_case){
      FactoryGirl.create(:business_case, testing_ground: testing_ground)
    }

    it 'updates the current business case' do
      put :update, testing_ground_id: testing_ground.id, id: business_case.id,
                   business_case: {
                     financials: JSON.dump([{row: 'customer', tariff: 123 }])
                   }

      expect(business_case.reload.financials).to eq(JSON.dump(
        [{row: 'customer', tariff: 123}])
      )
    end
  end

  describe "#edit" do
    let(:business_case){
      FactoryGirl.create(:business_case, testing_ground: testing_ground)
    }

    it "visits the edit path of the business case" do
      get :edit, testing_ground_id: testing_ground.id, id: business_case.id

      expect(response).to be_success
    end
  end

  describe "illegal update" do
    let(:business_case){
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

  describe "#show" do
    let(:business_case){
      FactoryGirl.create(:business_case)
    }

    it 'visits show page' do
      get :show, testing_ground_id: testing_ground.id, id: business_case.id

      expect(response).to be_success
    end
  end
end
