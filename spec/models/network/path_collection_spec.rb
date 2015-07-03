require 'rails_helper'

RSpec.describe Network::PathCollection do
  let(:source) { [ 'ab', 'aa', 'b', 'c', 'd'] }

  let(:collection) do
    Network::PathCollection.new(source, [
      ->(s) { s.start_with?('a') },
      ->(s) { s.start_with?('b') }
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

  it 'ends with items for which no proc was truthy' do
    expect(collection.to_a).to end_with('c', 'd')
  end
end
