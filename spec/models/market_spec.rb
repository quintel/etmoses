require 'rails_helper'

RSpec.describe Network do
  describe '.build' do
    let(:data) do
      {
        stakeholders: [
          { name: 'Stakeholder 1' },
          { name: 'Stakeholder 2' }
        ],
        relations: [
          { from: 'Stakeholder 1', to: 'Stakeholder 2' }
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

        it 'has a stakeholder assigned' do
          expect(node.get(:stakeholder).name).to eq('Stakeholder 1')
        end
      end # the first node

      context 'the second node' do
        let(:node) { market.node('Stakeholder 2') }

        it 'exists' do
          expect(node).to be
        end

        it 'has a stakeholder assigned' do
          expect(node.get(:stakeholder).name).to eq('Stakeholder 2')
        end
      end # the second node

      context 'the relation' do
        let(:relation) { market.node('Stakeholder 1').out_edges.first }

        it 'exists' do
          expect(relation.to.key).to eq('Stakeholder 2')
        end
      end # the relation
    end # with a simple two-node market

    context 'where the :from end of a relation does not exist' do
      before do
        data[:relations].first[:from] = '_invalid_'
      end

      it 'raises an error' do
        expect { market }.to raise_error(Market::NoSuchStakeholderError)
      end
    end # where the :from end of a relation does not exist

    context 'where the :to end of a relation does not exist' do
      before do
        data[:relations].first[:to] = '_invalid_'
      end

      it 'raises an error' do
        expect { market }.to raise_error(Market::NoSuchStakeholderError)
      end
    end # where the :to end of a relation does not exist

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
  end # with a simple two-node market
end
