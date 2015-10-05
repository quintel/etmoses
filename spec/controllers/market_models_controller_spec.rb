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
end
