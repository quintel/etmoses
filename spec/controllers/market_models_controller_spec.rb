require 'rails_helper'

RSpec.describe MarketModelsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:testing_ground) { FactoryGirl.create(:testing_ground, user: user) }
  let(:market_model) { FactoryGirl.create(:market_model, testing_ground: testing_ground) }

  let!(:sign_in_user) { sign_in(user) }

  describe '#replace' do
    let(:market_model) do
      FactoryGirl.create(
        :market_model,
        interactions: [],
        testing_ground: testing_ground
      )
    end

    let(:template) { FactoryGirl.create(:market_model_template) }

    let(:request) do
      patch :replace,
        testing_ground_id: testing_ground.id,
        id: market_model.id,
        replacement_id: template.id,
        format: :js
    end

    it 'sets the new interactions' do
      expect { request }
        .to change { market_model.reload.interactions }
        .from([]).to(template.interactions)
    end

    it 'sets the new template ID' do
      expect { request }
        .to change { market_model.reload.market_model_template_id }
        .to(template.id)
    end
  end

  describe "#update" do
    let!(:business_case) {
      FactoryGirl.create(:business_case, testing_ground: testing_ground, job_id: 1)
    }

    let!(:control_group) {
      FactoryGirl.create(:business_case, job_id: 2)
    }

    before do
      patch :update,
        testing_ground_id: testing_ground.id,
        id: market_model.id,
        market_model: {
          name: "test", public: true, interactions: []
        }, format: :js
    end

    it "should recalculate the business case for all LES's with the same market model id as the given id" do
      expect(business_case.reload.job_id).to eq(nil)
    end

    it "should not change other business case job id's" do
      expect(control_group.job_id).to eq(2)
    end
  end
end
