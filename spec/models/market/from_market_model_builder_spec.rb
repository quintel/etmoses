require 'rails_helper'

RSpec.describe Market::FromMarketModelBuilder do
  let(:les) do
    create(:testing_ground,
      topology: build(:topology_with_stakeholders)).to_calculated_graph
  end

  let(:market) { Market::FromMarketModelBuilder.new(mm, les).to_market }

  describe 'given a market model with two stakeholders' do
    let(:mm) do
      MarketModel.new(interactions: JSON.dump([{
        'stakeholder_from' => 'system operator',
        'stakeholder_to'   => 'customer',
        'foundation'       => 'kWh',
        'tariff'           => 5.0
      }]))
    end

    it 'creates the "from" stakeholder' do
      expect(market.node('system operator')).to be
    end

    it 'creates the "to" stakeholder' do
      expect(market.node('customer')).to be
    end

    it 'assigns nodes from the LES to the Customer group' do
      expect(market.node('customer').get(:measurables))
        .to eq([les.node('lv1'), les.node('lv2')])
    end

    it 'assigns nodes from the LES to the Supplier group' do
      expect(market.node('system operator').get(:measurables))
        .to eq([les.node('hv')])
    end
  end # given a market model with two stakeholders
end
