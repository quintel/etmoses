require 'rails_helper'

RSpec.describe NetworkCache::Writer do
  let(:testing_ground) do
    FactoryGirl.create(
      :testing_ground,
      topology: FactoryGirl.create(:topology_caching)
    )
  end

  let(:network) do
    NetworkCache::Fetcher.from(testing_ground, opts).fetch.detect do |net|
      net.carrier == :electricity
    end
  end

  context 'with no calculation options' do
    let(:opts) { {} }

    it 'writes to cache' do
      NetworkCache::Writer.from(testing_ground, opts).write
      expect(network.node('lv1').get(:load)).to eq([1])
    end
  end

  context 'with calculation options' do
    let(:opts) { { strategies: { saving_base_load: true } } }

    it 'writes strategies to a separate cache' do
      NetworkCache::Writer.from(testing_ground, opts).write
      expect(network.node('lv1').get(:load)).to eq([1])
    end
  end
end
