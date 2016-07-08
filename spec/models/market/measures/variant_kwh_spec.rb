require 'rails_helper'

module Market::Measures
  RSpec.describe VariantKwh do
    let(:node) do
      Network::Node.new(:thing, resolution: 1.0)
    end

    let(:variant) do
      Network::Node.new(:thing, resolution: 1.0, load: [1.0, 2.0, -4.0, -0.5])
    end

    let(:variants) do
      { gas: ->*{}, heat: ->*{ variant } }
    end

    context 'with no :gas; a :heat variant with loads [1.0, 2.0, -4.0, -0.5]' do
      context 'measuring gas consumed' do
        let(:measure) { VariantKwh.new(:gas, :consumed) }

        it 'returns 0' do
          expect(measure.call(node, variants)).to eq([])
        end
      end # measuring gas consumed

      context 'measuring gas produced' do
        let(:measure) { VariantKwh.new(:gas, :produced) }

        it 'returns 0' do
          expect(measure.call(node, variants)).to eq([])
        end
      end # measuring gas produced

      context 'measuring heat consumed' do
        let(:measure) { VariantKwh.new(:heat, :consumed) }

        it 'returns the consumption loads: [1, 2, 0, 0]' do
          expect(measure.call(node, variants)).to eq([1.0, 2.0, 0.0, 0.0])
        end
      end # measuring heat consumed

      context 'measuring heat produced' do
        let(:measure) { VariantKwh.new(:heat, :produced) }

        it 'returns the production loads: [0, 0, 4, 0.5]' do
          expect(measure.call(node, variants)).to eq([0.0, 0.0, 4.0, 0.5])
        end
      end # measuring heat produced
    end # with a :heat variant and loads [1.0, 2.0, -4.0, -0.5]
  end # VariantKwh
end
