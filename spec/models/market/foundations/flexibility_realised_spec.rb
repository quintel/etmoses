require 'rails_helper'

module Market::Foundations
  RSpec.describe KwhProduced do
    let(:node)     { Network::Node.new(:node, resolution: 1) }
    let(:variant)  { Network::Node.new(:node, resolution: 1) }
    let(:variants) { { basic: ->*{ variant } } }

    context 'given a node with loads [1, 2, 1, 3]' do
      before  { node.set(:load, [1.0, 2.0, 1.0, 3.0]) }

      context 'and variant of [2, 2, 3, 3]' do
        before  { variant.set(:load, [2.0, 2.0, 3.0, 3.0]) }

        it 'has total flexibility of 3 kWh' do
          expect(FlexibilityRealised.call(node, variants)).to eq(3)
        end
      end # and variant of [2, 2, 3, 3]

      context 'and variant of [1, 2, 1, 3]' do
        before  { variant.set(:load, [1.0, 2.0, 1.0, 3.0]) }

        it 'has total flexibility of 0 kWh' do
          expect(FlexibilityRealised.call(node, variants)).to be_zero
        end
      end # and variant of [1, 2, 1, 3]
    end # given a node with loads [1, 2, 1, 3]
  end
end
