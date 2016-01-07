require 'rails_helper'

RSpec.describe NetworkCache::Fetcher do
  let(:technology_profile) {
    {
      'lv1' => [{
        name: "Tech one",
        profile: ([1.2] * 35040)
      }]
    }
  }

  let(:testing_ground) {
    FactoryGirl.create(:testing_ground, technology_profile: technology_profile)
  }

  let(:written_cache) { testing_ground.to_calculated_graphs }

  let!(:write_cache) {
    NetworkCache::Writer.from(testing_ground).write(written_cache)
  }

  let(:cache) { NetworkCache::Fetcher.from(testing_ground).fetch }

  it "fetches two graphs from cache" do
    expect(cache.length).to eq(2)
  end
end
