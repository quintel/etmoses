require 'rails_helper'

RSpec.describe NetworkCache::Validator do
  let(:testing_ground){ FactoryGirl.create(:testing_ground, topology: FactoryGirl.create(:topology_caching)) }

  it "marks the network cache as invalid" do
    expect(NetworkCache::Validator.from(testing_ground).valid?).to eq(false)
  end

  it 'validates the network cache' do
    NetworkCache::Writer.from(testing_ground).write

    expect(NetworkCache::Validator.from(testing_ground).valid?).to eq(true)
  end

  it 'validates the network cache with strategies' do
    old_strategies = FakeLoadManagement.strategies(solar_storage: true)
    SelectedStrategy.create!(old_strategies.merge(testing_ground: testing_ground))
    NetworkCache::Writer.from(testing_ground, old_strategies).write

    expect(NetworkCache::Validator.from(testing_ground, old_strategies).valid?).to eq(true)
  end

  it 'marks the network cache as invalid with the wrong strategies' do
    old_strategies = FakeLoadManagement.strategies(solar_storage: true)
    SelectedStrategy.create!(old_strategies.merge(testing_ground: testing_ground))
    NetworkCache::Writer.from(testing_ground, old_strategies).write

    new_strategies = FakeLoadManagement.strategies(battery_storage: true)

    expect(NetworkCache::Validator.from(testing_ground, new_strategies).valid?).to eq(false)
  end

  it 'marks the network cache as invalid with the wrong strategies' do
    testing_ground.update(updated_at: Time.now + 1.hour)
    NetworkCache::Writer.from(testing_ground).write

    expect(NetworkCache::Validator.from(testing_ground).valid?).to eq(false)
  end
end
