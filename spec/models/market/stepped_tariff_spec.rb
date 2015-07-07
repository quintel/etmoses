require 'rails_helper'

RSpec.describe Market::SteppedTariff do
  context 'with only a lowest price and no steps' do
    let(:tariff) { Market::SteppedTariff.new(10.0) }

    it 'returns the lowest price given 0' do
      expect(tariff.price_of(0)).to eq(10.0)
    end

    it 'returns the lowest price given 1' do
      expect(tariff.price_of(2)).to eq(10.0)
    end

    it 'returns the lowest price given 2' do
      expect(tariff.price_of(2)).to eq(10.0)
    end
  end # with only a lowest price and no steps

  context 'with a lowest price and one step' do
    let(:tariff) { Market::SteppedTariff.new(10.0, [[2, 20.0]]) }

    it 'returns the lowest price given 0' do
      expect(tariff.price_of(0)).to eq(10.0)
    end

    it 'returns the lowest price given 1' do
      expect(tariff.price_of(1)).to eq(10.0)
    end

    it 'returns the lowest price given 2' do
      expect(tariff.price_of(2)).to eq(20.0)
    end

    it 'returns the lowest price given 3' do
      expect(tariff.price_of(3)).to eq(20.0)
    end
  end # with a lowest price and one step


  context 'with a lowest price and two steps' do
    let(:tariff) { Market::SteppedTariff.new(10.0, [[2, 20.0], [4, 30.0]]) }

    it 'returns the lowest price given 0' do
      expect(tariff.price_of(0)).to eq(10.0)
    end

    it 'returns the middle price given 2' do
      expect(tariff.price_of(2)).to eq(20.0)
    end

    it 'returns the highest price given 4' do
      expect(tariff.price_of(4)).to eq(30.0)
    end
  end # with a lowest price and two steps

  context 'with a lowest price and two decreasing steps' do
    let(:tariff) { Market::SteppedTariff.new(10.0, [[2, 5.0], [4, 2.0]]) }

    it 'returns the staring price given 0' do
      expect(tariff.price_of(0)).to eq(10.0)
    end

    it 'returns the middle price given 2' do
      expect(tariff.price_of(2)).to eq(5.0)
    end

    it 'returns the final price given 4' do
      expect(tariff.price_of(4)).to eq(2.0)
    end
  end # with a lowest price and two steps
end
