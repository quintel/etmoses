require 'rails_helper'

RSpec.describe NetworkCache::Writer do
  let(:testing_ground){ FactoryGirl.create(:testing_ground, topology: FactoryGirl.create(:topology_caching)) }

  it 'writes to cache' do
    NetworkCache::Writer.from(testing_ground).write

    expect(NetworkCache::Fetcher.from(testing_ground).fetch.node('lv1').get(:load)).to eq([1])
  end

  it 'writes strategies to a separate cache' do
    NetworkCache::Writer.from(testing_ground, { saving_base_load: true })
           .write

    expect(NetworkCache::Fetcher.from(testing_ground, { saving_base_load: true  })
           .fetch.node('lv1').get(:load)).to eq([1])
  end
end
