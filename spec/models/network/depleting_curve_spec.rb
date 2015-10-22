require 'rails_helper'

RSpec.describe Network::DepletingCurve do
  let(:original) { Network::Curve.new(values) }
  let(:curve)    { Network::DepletingCurve.new(original) }

  context 'with values of 1.0 and 2.0' do
    let(:values) { [1.0, 2.0] }

    context 'prior to assigning anything' do
      it 'does not affect the amount required in frame 0' do
        expect(curve.get(0)).to eq(original.get(0))
      end

      it 'does not affect the amount required in frame 1' do
        expect(curve.get(1)).to eq(original.get(1))
      end
    end

    context 'after assigning use of 0.5 to frame 0' do
      before { curve.deplete(0, 0.5) }

      it 'reduces the amount required in frame 0 to 0.5' do
        expect(curve.get(0)).to eq(0.5)
      end

      it 'does not affect the amount required in frame 1' do
        expect(curve.get(1)).to eq(2.0)
      end
    end


    context 'after assigning use of 1.5 to frame 0' do
      before { curve.deplete(0, 1.0) }

      it 'reduces the amount required in frame 0 to zero' do
        expect(curve.get(0)).to be_zero
      end

      it 'does not affect the amount required in frame 1' do
        expect(curve.get(1)).to eq(2.0)
      end
    end
  end # with values of 1.0 and 2.0
end
