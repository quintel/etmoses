require 'rails_helper'

RSpec.describe MeritController do
  let(:user){ FactoryGirl.create(:user) }

  describe 'merit order' do
    let(:testing_ground){ FactoryGirl.create(:testing_ground) }

    let!(:sign_in_user){ sign_in(user) }

    it 'creates a merit order' do
      stub_request(:get, "http://beta.et-engine.com/api/v3/scenarios/1/merit").
        with(:headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip, deflate', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
        to_return(:status => 200, :body => JSON.dump({participants: [], profiles: []}))

      NetworkCache::Writer.from(testing_ground).write(TreeToGraph.convert({
          name: "hv",
          load: [0.0] * 8760,
          children: [{
            name: 'mv',
            load: [0.0] * 8760,
            children: [
              { name: 'lv1', load: [0.0] * 8760 },
              { name: 'lv2', load: [0.0] * 8760 }
            ]
          }]
        }))

      get :price_curve, testing_ground_id: testing_ground.id, format: :csv

      expect(response).to be_success
    end
  end

end
