require 'rails_helper'

RSpec.describe TestingGroundsController do
  let(:user){ FactoryGirl.create(:user) }

  let!(:sign_in_user) { sign_in(:user, user) }

  let(:topology_graph){ FakeLoadManagement.caching_graph }

  let(:topology){ FactoryGirl.create(:topology, graph: topology_graph) }

  let(:testing_ground){
    FactoryGirl.create(:testing_ground, technology_profile: technology_profile,
                                        topology: topology)
  }

  let(:load_profile){
    FactoryGirl.create(:load_profile)
  }

  let!(:load_profile_components){
    FactoryGirl.create(:load_profile_component,
      curve: curve, curve_type: "default", load_profile: load_profile)
  }

  let!(:technology_profile_couple){
    FactoryGirl.create(:technology_profile, load_profile: load_profile,
                       technology: "households_solar_pv_solar_radiation")
  }

  let(:points){
    @points ||= 8760.times.map{|i| rand(0.0...0.5) }
  }

  let(:curve){
    File.write("#{Rails.root}/spec/fixtures/points.tmp.csv", points.to_csv(col_sep: "\n"), mode: 'wb')
    fixture_file_upload("points.tmp.csv", 'text/csv')
  }

  let(:technology_profile){
    { "CONGESTED_END_POINT_0" => [{
        "name"        => "Solar PV",
        "type"        => "households_solar_pv_solar_radiation",
        "behavior"    => nil,
        "profile"     => load_profile.id,
        "load"        => nil,
        "capacity"    => -1.5,
        "demand"      => nil,
        "volume"      => nil,
        "units"       => 1,
        "concurrency" => "max"
      }]
    }
  }

  describe 'caching' do
    it 'caches the data request' do
      get :data, id: testing_ground

      expect(NetworkCache::Reader.from(testing_ground)
              .read('CONGESTED_END_POINT_0').length).to eq(8760)
    end

    it 'caches the data request for strategies separately' do
      get :data, id: testing_ground,
                 strategies: FakeLoadManagement.strategies(saving_base_load: true)

      expect(NetworkCache::Reader.from(testing_ground, { saving_base_load: true })
              .read('CONGESTED_END_POINT_0').length
            ).to eq(8760)
    end

    it 'fetches the data instead of calculating' do
      technology_profile.each_pair do |key, value|
        NetworkCache::Writer.from(testing_ground).write(key, points)
      end

      get :data, id: testing_ground

      expect(NetworkCache::Reader.from(testing_ground)
              .read('CONGESTED_END_POINT_0').length).to eq(8760)
    end

    it 'clears the data cache' do
      technology_profile.each_pair do |key, value|
        NetworkCache::Writer.from(testing_ground).write(key, points)
      end

      get :data, id: testing_ground, clear_cache: true

      expect(NetworkCache::Reader.from(testing_ground)
              .read('CONGESTED_END_POINT_0').length).to eq(8760)
    end
  end
end
