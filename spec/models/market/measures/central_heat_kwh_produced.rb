require 'rails_helper'

module Market::Measures
  RSpec.describe CentralHeatKwhProduced do
    let(:node) do
      Network::Node.new(:thing, resolution: 1.0)
    end

    let(:variant) do
      Network::Node.new(:thing, resolution: 1.0, load: [1.0, 2.0, -4.0, -0.5])
    end

    let(:variants) do
      { heat: ->*{ variant } }
    end

    context 'when there is no heat variant' do
      let(:variants) { { heat: ->*{} } }

      it 'returns zero' do
        expect(CentralHeatKwhProduced.call(node, variants)).to be_zero
      end
    end # when there is no heat variant

    context 'with a top-level heat node and loads [2.0, 3.0, -1.0, 0]' do
      it 'returns [1.0, 2.0, 0, 0]' do
        expect(CentralHeatKwhProduced.call(node, variants)).
          to eq([1.0, 2.0, 0.0, 0.0])
      end
    end # with a top-level heat node and loads [2.0, 3.0, -1.0, 0]

    context 'with a mid-level node and loads [2.0, 3.0, -1.0, 0]' do
      before { Network::Node.new(:parent).connect_to(variant, :heat) }

      it 'returns zero' do
        expect(CentralHeatKwhProduced.call(node, variants)).to be_zero
      end
    end # with a mid-level node and loads [2.0, 3.0, -1.0, 0]
  end # CentralHeatKwhProduced
end
