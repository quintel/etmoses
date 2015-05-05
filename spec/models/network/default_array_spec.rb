require 'rails_helper'

RSpec.describe Network::DefaultArray do
  context 'initialized with no starting array' do
    let(:default) { Network::DefaultArray.new { |v| v } }

    it 'raises no error' do
      expect { default }.to_not raise_error
    end

    it 'defaults to an empty array' do
      expect(default.to_a).to eq([])
    end

    it 'sets default values when accessed' do
      default[0]
      expect(default.first).to eq(0)
    end

    it 'sets given values' do
      default[1] = 2
      expect(default[1]).to eq(2)
    end
  end # initialized with no starting array

  context 'initialized with a starting array' do
    let(:default) { Network::DefaultArray.new([1, 2, 3]) { |v| v } }

    it 'returns the array when calling to_a' do
      expect(default.to_a).to eq([1, 2, 3])
    end

    it 'returns pre-set values' do
      expect(default[1]).to eq(2)
    end

    it 'sets default values when accessed' do
      expect(default[5]).to eq(5)
    end
  end # initialized with a starting array

  context 'initialized with no block' do
    it 'raises an ArgumentError' do
      expect { Network::DefaultArray.new([]) }.to raise_error(ArgumentError)
    end
  end # initalized with no block

  it 'executes each default block once per key' do
    called  = 0
    default = Network::DefaultArray.new { |v| called += 1 }

    default[0]
    default[0]

    expect(called).to eq(1)

    default[1]

    expect(called).to eq(2)
  end
end
