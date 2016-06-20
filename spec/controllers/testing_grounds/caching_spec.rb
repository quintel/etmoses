require 'rails_helper'

RSpec.describe TestingGroundsController do
  before do
    expect(Settings.cache).
      to receive(:networks).at_least(:once).and_return(true)
  end

  let(:user){ FactoryGirl.create(:user) }

  let!(:sign_in_user) { sign_in(:user, user) }

  let(:topology_graph){ FakeLoadManagement.caching_graph(1, [0.0] * 8760) }

  let(:topology){ FactoryGirl.create(:topology, graph: topology_graph) }

  let(:testing_ground){
    FactoryGirl.create(:testing_ground, technology_profile: technology_profile,
                                        topology: topology)
  }

  let(:technology_profile){
    { "CONGESTED_END_POINT_0" => [{
        "name"        => "Solar PV",
        "type"        => "households_solar_pv_solar_radiation",
        "load"        => nil,
        "capacity"    => -1.5,
        "demand"      => nil,
        "volume"      => nil,
        "units"       => 1,
        "concurrency" => "max"
      }]
    }
  }

  let(:network) do
    NetworkCache::Fetcher.from(testing_ground, opts).fetch.detect do |net|
      net.carrier == :electricity
    end
  end

  describe 'caching' do
    let(:opts) { { strategies: {} } }

    it 'caches the data request' do
      get :data, id: testing_ground

      loads = network.node('CONGESTED_END_POINT_0').get(:load)
      expect(loads.length).to eq(8760)
    end

    context 'with custom calculation options' do
      let(:opts) { { strategies: { saving_base_load: true } } }

      it 'caches the data request for strategies separately' do
        get :data, id: testing_ground,
                   calculation: opts

        loads = network.node('CONGESTED_END_POINT_0').get(:load)
        expect(loads.length).to eq(8760)
      end
    end

    it 'fetches the data instead of calculating' do
      NetworkCache::Writer.from(testing_ground, opts).write

      get :data, id: testing_ground

      loads = network.node('CONGESTED_END_POINT_0').get(:load)
      expect(loads.length).to eq(8760)
    end

    it 'clears the data cache' do
      NetworkCache::Writer.from(testing_ground, opts).write

      get :data, id: testing_ground, clear_cache: true

      loads = network.node('CONGESTED_END_POINT_0').get(:load)
      expect(loads.length).to eq(8760)
    end
  end
end
