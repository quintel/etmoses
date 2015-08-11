require 'rails_helper'

RSpec.describe Network do
  describe '.build' do
    let(:data) do
      {
        relations: [
          { from: 'Stakeholder 1', to: 'Stakeholder 2',
            foundation: ->{ 2 }, tariff: 2 }
        ]
      }
    end

    let(:market) { Market.build(data) }

    context 'with a simple two-node market' do
      context 'the first node' do
        let(:node) { market.node('Stakeholder 1') }

        it 'exists' do
          expect(node).to be
        end
      end # the first node

      context 'the second node' do
        let(:node) { market.node('Stakeholder 2') }

        it 'exists' do
          expect(node).to be
        end
      end # the second node

      context 'the relation' do
        let(:relation) { market.node('Stakeholder 1').out_edges.first }

        it 'exists' do
          expect(relation.to.key).to eq('Stakeholder 2')
        end

        it 'sets the foundation' do
          expect(relation.price).to be_zero
        end
      end # the relation
    end # with a simple two-node market

    context 'with a named foundation' do
      let(:relation) { market.node('Stakeholder 1').out_edges.first }

      let(:measurable) do
        Network::Node.new(:fake).tap do |measurable|
          allow(measurable).to receive(:energy_at).and_return(4.0)
          allow(measurable).to receive(:load).and_return([4.0])
        end
      end

      before do
        data[:relations].first[:foundation] = :kwh
        data[:measurables] = { 'Stakeholder 2' => [measurable] }
      end

      it 'sets the foundation' do
        expect(relation.price).to eq(8.0)
      end
    end # with a named foundation

    context 'with nil' do
      let(:data) { nil }

      it 'raises an error' do
        expect { market }.to raise_error(/invalid data: nil/i)
      end
    end # with nil

    context 'with no data' do
      let(:data) { {} }

      it 'raises an error' do
        expect { market }.to raise_error(/invalid data: {}/i)
      end
    end # with no data

    context 'with no tariff' do
      before do
        data[:relations].first.delete(:tariff)
      end

      it 'raises an error' do
        expect { market }.to raise_error(/invalid tariff: nil/i)
      end
    end
  end # with no tariff
end
