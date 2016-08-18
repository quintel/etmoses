require 'rails_helper'

RSpec.describe DataController do
  let(:user){ FactoryGirl.create(:user) }

  describe 'merit order' do
    let(:testing_ground){ FactoryGirl.create(:testing_ground) }

    let!(:sign_in_user){ sign_in(user) }

    before do
      expect(Settings.cache).to receive(:networks).and_return(true)
    end

    it 'creates a merit order' do
      stub_request(:get, "https://beta.et-engine.com/api/v3/scenarios/1/merit").
        with(:headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip, deflate', 'Content-Type'=>'application/json'}).
        to_return(:status => 200, :body => JSON.dump({participants: [], profiles: []}))

      NetworkCache::Writer.from(testing_ground).write([
        Network::Builders::Electricity.build({
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
        }),
        Network::Builders::Gas.build({}, {})
      ])

      get :price_curve, testing_ground_id: testing_ground.id, format: :csv

      expect(response).to be_success
    end
  end

end
