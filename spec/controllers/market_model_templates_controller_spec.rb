require 'rails_helper'

RSpec.describe MarketModelTemplatesController do
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

  describe "#create" do
    it 'creating a market model template' do
      sign_in(:user, FactoryGirl.create(:user))

      post :create, "market_model_template"=>{
        "name"=>"Hello",
        "interactions"=>"[]"
      }

      expect(MarketModelTemplate.count).to eq(2) # + the default
    end
  end

  describe "#show" do
    it 'visits show path' do
      market_model_template = FactoryGirl.create(:market_model_template, public: true)

      get :show, id: market_model_template.id

      expect(response.code).to eq("200")
    end

    it 'doesnt visit private show path' do
      market_model_template = FactoryGirl.create(:market_model_template, public: false)

      get :show, id: market_model_template.id

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "#update" do
    let!(:sign_in_user) { sign_in(:user, user) }

    let(:market_model_template) {
      FactoryGirl.create(:market_model_template, user: user)
    }

    before do
      patch :update, id: market_model_template.id,
        market_model_template: { name: "Empty market model", featured: true }
    end

    describe "normal user" do
      let(:user) { FactoryGirl.create(:user) }

      it "should be able to update the market model template" do
        expect(market_model_template.reload.name).to eq("Empty market model")
      end

      it "should not be possible to set it as featured" do
        expect(market_model_template.reload.featured).to eq(false)
      end
    end

    describe "admin user" do
      let(:user) { FactoryGirl.create(:user, admin: true) }

      it "should be able to update the market model template" do
        expect(market_model_template.reload.name).to eq("Empty market model")
      end

      it "should be possible to set it as featured" do
        expect(market_model_template.reload.featured).to eq(true)
      end
    end
  end

  describe "#destroy" do
    let(:user) { FactoryGirl.create(:user) }
    let!(:sign_in_user) { sign_in(:user, user) }

    let(:market_model_template) {
      FactoryGirl.create(:market_model_template, user: user)
    }

    let!(:market_model) {
      FactoryGirl.create(:market_model,
        market_model_template: market_model_template)
    }

    let!(:unaffected_market_model) {
      FactoryGirl.create(:market_model)
    }

    before do
      delete :destroy, id: market_model_template.id
    end

    it 'destroys a market model template' do
      expect(MarketModelTemplate.count).to eq(2) # The default remains + the unaffected
    end

    it "sets the market model template id to nil" do
      expect(market_model.reload.market_model_template_id).to eq(nil)
    end

    it "doesn't affect other market models" do
      expect(unaffected_market_model.reload.market_model_template_id).to_not be_blank
    end
  end

  describe '#clone' do
    let(:user) { FactoryGirl.create(:user) }
    let!(:sign_in_user) { sign_in(user) }

    let!(:market_model_template) do
      FactoryGirl.create(:market_model_template, user: user)
    end

    describe 'with a new name' do
      let(:request) do
        patch :clone,
          id: market_model_template,
          market_model_template: { name: 'new name' },
          format: :json
      end

      it 'duplicates templates' do
        expect { request }.to change { MarketModelTemplate.count }.by(1)
      end

      it 'has a "new name"' do
        request
        expect(MarketModelTemplate.last.name).to eq('new name')
      end
    end

    describe 'with no name at all' do
      let(:request) do
        patch :clone,
          id: market_model_template,
          market_model_template: { name: '' },
          format: :json
      end

      it 'duplicates templates' do
        expect { request }.to_not change { MarketModelTemplate.count }
      end

      it 'returns a 422 status' do
        request
        expect(response.code).to eq('422')
      end
    end
  end
end
