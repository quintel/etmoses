require 'rails_helper'

RSpec.describe Market::CurveTariff do
  context 'with a curve containing [1.0, 2.0]' do
    let(:curve)  { Network::Curve.new([1.0, 2.0]) }
    let(:tariff) { Market::CurveTariff.new(curve) }

    it 'prices arrays of values' do
      expect(tariff.price_of([2.0, 3.0])).to eq(8.0)
    end

    it 'raises an error if there are too many values' do
      expect { tariff.price_of([1, 2, 3]) }
        .to raise_error(Market::CurveLengthError)
    end

    it 'raises an error if there are too few values' do
      expect { tariff.price_of([1]) }
        .to raise_error(Market::CurveLengthError)
    end

    it 'raises an error given an array' do
      expect { Market::CurveTariff.new([1, 2]) }
        .to raise_error(Market::InvalidCurveError)
    end
  end
end
