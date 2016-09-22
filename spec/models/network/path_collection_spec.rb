require 'rails_helper'

RSpec.describe Network::PathCollection do
  context 'with a single sorter' do
    let(:source) { %w(ab aa b c d) }

    let(:collection) do
      Network::PathCollection.new(source, [
        ->(s) { %w(a b).index(s[0]) }
      ])
    end

    it 'places first those items which for which the first proc is truthy' do
      first = collection.take(2)

      expect(first).to include('aa')
      expect(first).to include('ab')
    end

    it 'preserves the original order, when possible' do
      as_array = collection.to_a
      expect(as_array.index('aa')).to be > as_array.index('ab')
    end

    it 'places second those items for which the second proc is truthy' do
      as_array = collection.to_a
      expect(as_array.index('b')).to be > as_array.index('aa')
    end

    it 'ends with items for which no value was returned' do
      expect(collection.to_a).to end_with('c', 'd')
    end
  end

  context 'with multiple sorters' do
    let(:source) { %w(ab aa ab b c d) }

    let(:collection) do
      Network::PathCollection.new(source, [
        ->(s) { %w(a b).index(s[0]) },
        ->(s) { %w(b a).index(s[1]) }
      ])
    end

    it 'places first those items which for which the first proc is truthy' do
      first = collection.take(3)

      expect(first).to include('aa')
      expect(first).to include('ab')
    end

    it 'breaks ties with the second sorter' do
      as_array = collection.to_a
      # Assert that aa appears after both of ab
      expect(as_array.index('aa')).to be > as_array.rindex('ab')
    end

    it 'places second those items for which the second proc is truthy' do
      as_array = collection.to_a
      expect(as_array.index('b')).to be > as_array.index('aa')
    end

    it 'ends with items for which no value was returned' do
      expect(collection.to_a).to end_with('c', 'd')
    end
  end
end
