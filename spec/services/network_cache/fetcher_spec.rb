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

  let(:written_cache) { testing_ground.to_calculated_graphs(range: 0..35040) }

  describe "default behavior" do
    let!(:write_cache) {
      NetworkCache::Writer.from(testing_ground).write(written_cache)
    }

    describe "full cache" do
      let(:cache) { NetworkCache::Fetcher.from(testing_ground).fetch }

      it "fetches two graphs from cache" do
        expect(cache.length).to eq(2)
      end

      it "fetches cache" do
        expect(cache[0].nodes.map(&:load).map(&:first)).to eq([1.2, 1.2, 1.2, 0.0])
      end
    end

    describe "partial cache" do
      let(:cache) { NetworkCache::Fetcher.from(testing_ground).fetch(%w(lv1)) }

      it "fetches two graphs from cache" do
        expect(cache[0].nodes.map(&:load).map(&:first)).to eq([nil, nil, 1.2, nil])
      end
    end
  end

  describe "year current week behavior" do
    let!(:write_cache) {
      NetworkCache::Writer.from(testing_ground,
        resolution: :low, strategies: {}, range: 0..35040).write(written_cache)
    }

    describe "when fetching low resolution cache it should just fetch" do
      let(:cache) { NetworkCache::Fetcher.from(testing_ground,
        resolution: :high, strategies: {}, range: 0..20).fetch }

      it "fetches cache" do
        expect(cache[0].nodes.map(&:load).map(&:first)).to eq([1.2, 1.2, 1.2, 0.0])
      end
    end
  end
end
