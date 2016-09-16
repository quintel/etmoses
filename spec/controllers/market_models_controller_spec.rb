require 'rails_helper'

RSpec.describe MarketModelsController do
  describe "#index" do
    it 'visits index path' do
      get :index

      expect(response.status).to eq(200)
    end

    it 'visits new market model view' do
      sign_in(:user, FactoryGirl.create(:user))

      get :new

      expect(response.status).to eq(200)
    end
  end

  describe "#show" do
    it 'visits show path' do
      market_model = FactoryGirl.create(:market_model, public: true)

      get :show, id: market_model.id

      expect(response.code).to eq("200")
    end

    it 'doesnt visit private show path' do
      market_model = FactoryGirl.create(:market_model, public: false)

      get :show, id: market_model.id

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "#update" do
    let(:user) { FactoryGirl.create(:user) }
    let(:market_model) { FactoryGirl.create(:market_model, user: user) }
    let(:business_cases) {
      BusinessCase.where(testing_ground: TestingGround.where(market_model: market_model))
    }

    let(:control_group) {
      FactoryGirl.create(:business_case, job_id: 2)
    }

    before do
      sign_in(:user, user)

      3.times do
        testing_ground = FactoryGirl.create(:testing_ground,
          market_model: market_model)

        FactoryGirl.create(:business_case,
                           testing_ground: testing_ground, job_id: 1)
      end

      patch :update, id: market_model.id, market_model: {
        name: "test", public: true, interactions: [] }
    end

    it "should recalculate the business case for all LES's with the same market model id as the given id" do
      expect(business_cases.pluck(:job_id)).to eq([nil, nil, nil])
    end

    it "should not change other business case job id's" do
      expect(control_group.job_id).to eq(2)
    end
  end
end
