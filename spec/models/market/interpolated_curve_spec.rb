require 'rails_helper'

RSpec.describe Market::InterpolatedCurve do
  context 'with [1, 2, 3, 4] and length 4' do
    let(:curve) { Market::InterpolatedCurve.new([1, 2, 3, 4], 4) }

    it 'returns 1 to get(0)' do
      expect(curve.get(0)).to eq(1)
    end

    it 'returns 2 to get(1)' do
      expect(curve.get(1)).to eq(2)
    end

    it 'returns 3 to get(2)' do
      expect(curve.get(2)).to eq(3)
    end

    it 'returns 4 to get(3)' do
      expect(curve.get(3)).to eq(4)
    end

    it 'returns 4 to at(3)' do
      # Sanity check
      expect(curve.at(3)).to eq(4)
    end

    it 'returns [1, 2, 3, 4] to #to_a' do
      expect(curve.to_a).to eq([1, 2, 3 ,4])
    end

    it 'enumerates over each item' do
      expect(curve.map.to_a).to eq([1, 2, 3 ,4])
    end
  end

  context 'with [1, 2, 3, 4] and length 8' do
    let(:curve) { Market::InterpolatedCurve.new([1, 2, 3, 4], 8) }

    it 'returns 1 to get(0)' do
      expect(curve.get(0)).to eq(1)
    end

    it 'returns 1 to get(1)' do
      expect(curve.get(1)).to eq(1)
    end

    it 'returns 2 to get(2)' do
      expect(curve.get(2)).to eq(2)
    end

    it 'returns 2 to get(3)' do
      expect(curve.get(3)).to eq(2)
    end

    it 'returns 4 to get(7)' do
      expect(curve.get(7)).to eq(4)
    end

    it 'returns [1, 1, 2, 2, 3, 3, 4, 4] to #to_a' do
      expect(curve.to_a).to eq([1, 1, 2, 2, 3, 3, 4, 4])
    end

    it 'enumerates over each item' do
      expect(curve.map.to_a).to eq([1, 1, 2, 2, 3, 3, 4, 4])
    end
  end

  context 'with [1, 2, 3, 4] and length 6' do
    let(:curve) { Market::InterpolatedCurve.new([1, 2, 3, 4], 6) }

    it 'raises an error' do
      expect { curve }.to raise_error(Market::InvalidInterpolationError)
    end
  end
end
