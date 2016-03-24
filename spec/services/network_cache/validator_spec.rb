require 'rails_helper'

RSpec.describe NetworkCache::Validator do
  let(:testing_ground) {
    FactoryGirl.create(:testing_ground,
      topology: FactoryGirl.create(:topology_caching))
  }

  before do
    expect(Settings.cache).to receive(:networks).and_return(true)
  end

  it "marks the network cache as invalid" do
    expect(NetworkCache::Validator.from(testing_ground).valid?).to eq(false)
  end

  it 'validates the network cache' do
    NetworkCache::Writer.from(testing_ground).write

    expect(NetworkCache::Validator.from(testing_ground).valid?).to eq(true)
  end

  it 'validates the network cache with strategies' do
    old_strategies = FakeLoadManagement.strategies(ev_storage: true)
    SelectedStrategy.create!(old_strategies.merge(testing_ground: testing_ground))
    NetworkCache::Writer.from(testing_ground, strategies: old_strategies).write

    expect(NetworkCache::Validator.from(testing_ground,
      strategies: old_strategies).valid?).to eq(true)
  end

  it 'marks the network cache as invalid with the wrong strategies' do
    old_strategies = FakeLoadManagement.strategies(ev_storage: true)
    SelectedStrategy.create!(old_strategies.merge(testing_ground: testing_ground))
    NetworkCache::Writer.from(testing_ground, strategies: old_strategies).write

    new_strategies = FakeLoadManagement.strategies(battery_storage: true)

    expect(NetworkCache::Validator.from(testing_ground,
      strategies: new_strategies).valid?).to eq(false)
  end

  it 'marks the network cache as invalid with the wrong strategies' do
    testing_ground.update(cache_updated_at: Time.now + 1.hour)
    NetworkCache::Writer.from(testing_ground).write

    expect(NetworkCache::Validator.from(testing_ground).valid?).to eq(false)
  end

  describe "caching parts of the load" do
    it 'marks the network cache as invalid when the range is incorrect' do
      testing_ground.update_attribute(:range, 1..5)
      NetworkCache::Writer.from(testing_ground).write

      expect(NetworkCache::Validator
        .from(testing_ground, strategies: {}, range: 0..35040).valid?).to eq(false)
    end

    it 'marks the network cache as valid with the correct range' do
      testing_ground.update_attribute(:range, 1..5)
      NetworkCache::Writer.from(testing_ground).write

      expect(NetworkCache::Validator
        .from(testing_ground, strategies: {}, range: 1..5).valid?).to eq(true)
    end

    it 'marks the network cache as valid when the range is correct for the resolution' do
      NetworkCache::Writer.from(testing_ground,
        strategies: {}, range: 0..35040, resolution: :low).write

      testing_ground.update_attribute(:range, 1..5)

      NetworkCache::Writer.from(testing_ground,
        strategies: {}, range: 0..5, resolution: :high).write

      expect(NetworkCache::Validator.from(testing_ground,
        strategies: {}, range: 0..35040, resolution: :low).valid?).to eq(true)
    end

    it 'marks the network cache as valid when a full year is already previously calculated' do
      NetworkCache::Writer.from(testing_ground,
        strategies: {}, range: 0..35040, resolution: :low).write

      testing_ground.update_attribute(:range, 1..5)

      NetworkCache::Writer.from(testing_ground).write

      expect(NetworkCache::Validator.from(testing_ground,
        strategies: {}, range: 0..10, resolution: :high).valid?).to eq(true)
    end
  end
end
