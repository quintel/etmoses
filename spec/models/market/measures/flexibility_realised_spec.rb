require 'rails_helper'

module Market::Measures
  RSpec.describe KwhProduced do
    let(:node)     { Network::Node.new(:node, resolution: 1) }
    let(:variant)  { Network::Node.new(:node, resolution: 1) }
    let(:variants) { { basic: ->*{ variant } } }
    let(:flex)     { FlexibilityRealised.call(node, variants) }

    context 'given a node with loads [1, 2, 1, 3]' do
      before  { node.set(:load, [1.0, 2.0, 1.0, 3.0]) }

      context 'and variant of [2, 2, 3, 3]' do
        before  { variant.set(:load, [2.0, 2.0, 3.0, 3.0]) }

        it 'has total flexibility of 1, 0, 2, 0 kWh' do
          expect(flex).to eq([1, 0, 2, 0])
        end
      end # and variant of [2, 2, 3, 3]

      context 'and variant of [1, 2, 1, 3]' do
        before  { variant.set(:load, [1.0, 2.0, 1.0, 3.0]) }

        it 'has total flexibility of 0 kWh' do
          expect(flex).to eq([0, 0, 0, 0])
        end
      end # and variant of [1, 2, 1, 3]

      context 'and variant of [-1, -2, -2, -3]' do
        before  { variant.set(:load, [-1.0, -2.0, -2.0, -3.0]) }

        it 'has total flexibility of 1 kWh' do
          expect(flex).to eq([0, 0, 1, 0])
        end
      end # and variant of [-1, -2, -2, -3]
    end # given a node with loads [1, 2, 1, 3]

    context 'given a node with loads [-1, -2, -1, -3]' do
      before  { node.set(:load, [-1.0, -2.0, -1.0, -3.0]) }

      context 'and variant of [-2, -2, -3, -3]' do
        before  { variant.set(:load, [-2.0, -2.0, -3.0, -3.0]) }

        it 'has total flexibility of 3 kWh' do
          expect(flex).to eq([1, 0, 2, 0])
        end
      end # and variant of [-2, -2, -3, -3]

      context 'and variant of [-1, -2, -1, -3]' do
        before  { variant.set(:load, [-1.0, -2.0, -1.0, -3.0]) }

        it 'has total flexibility of 0 kWh' do
          expect(flex).to eq([0, 0, 0, 0])
        end
      end # and variant of [-1, -2, -1, -3]

      context 'and variant of [1, 2, 2, 3]' do
        before  { variant.set(:load, [1.0, 2.0, 2.0, 3.0]) }

        it 'has total flexibility of 1 kWh' do
          expect(flex).to eq([0, 0, 1, 0])
        end
      end # and variant of [1, 2, 2, 3]
    end # given a node with loads [-1, -2, -1, -3]
  end
end
