require 'rails_helper'

RSpec.describe Market::Relation do
  describe '#price' do
    let(:data) do
      {
        stakeholders: [
          { name: 'Stakeholder 1' },
          { name: 'Stakeholder 2' }
        ],
        relations: [
          {
            from: 'Stakeholder 1',
            to:   'Stakeholder 2',
            measure: -> v { v * 2 },
            tariff: 2.0
          }
        ]
      }
    end

    let(:market) { Market.build(data) }

    before do
      market.node('Stakeholder 2').set(:measurables, [1.0, 2.0, 3.0])
    end

    # --------------------------------------------------------------------------

    it 'computes the price' do
      # (1 * 2 * 2) + (2 * 2 * 2) + (3 * 2 * 2)
      expect(market.relations.first.price).to eq(24)
    end
  end # #price
end
