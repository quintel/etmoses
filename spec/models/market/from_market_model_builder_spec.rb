require 'rails_helper'

RSpec.describe Market::FromMarketModelBuilder do
  let(:testing_ground) do
    tg = create(:testing_ground, topology: build(:topology_with_stakeholders))
    allow(tg).to receive(:market_model) { mm } #.and_return(mm)
    tg
  end

  let(:les) do
    testing_ground.to_calculated_graph
  end

  let(:market) do
    Market::FromMarketModelBuilder.new(testing_ground, les).to_market
  end

  describe 'given a market model with two stakeholders' do
    let(:mm) do
      MarketModel.new(interactions: [{
        'stakeholder_from' => 'customer',
        'stakeholder_to'   => 'system operator',
        'foundation'       => 'kWh',
        'tariff'           => 5.0,
        'tariff_type'      => 'fixed'
      }])
    end

    it 'creates the "from" stakeholder' do
      expect(market.node('system operator')).to be
    end

    it 'creates the "to" stakeholder' do
      expect(market.node('customer')).to be
    end

    it 'assigns nodes from the LES to the Customer group' do
      expect(market.node('customer').out_edges.first.get(:measurables))
        .to eq([les.node('lv1'), les.node('lv2')])
    end
  end # given a market model with two stakeholders

  describe 'given a market model with an applied_stakeholder' do
    let(:mm) do
      MarketModel.new(interactions: [{
        'stakeholder_from'    => 'customer',
        'stakeholder_to'      => 'system operator',
        'applied_stakeholder' => 'system operator',
        'foundation'          => 'kWh',
        'tariff'              => 5.0,
        'tariff_type'         => 'fixed'
      }])
    end

    it 'creates the "from" stakeholder' do
      expect(market.node('system operator')).to be
    end

    it 'creates the "to" stakeholder' do
      expect(market.node('customer')).to be
    end

    it 'assigns nodes from the LES to the Customer group' do
      expect(market.node('customer').out_edges.first.get(:measurables))
        .to eq([les.node('hv')])
    end
  end # given a market model with two stakeholders

  describe 'given a market model with a curve-based tariff' do
    let(:mm) do
      MarketModel.new(interactions: [{
        'stakeholder_from' => 'system operator',
        'stakeholder_to'   => 'customer',
        'foundation'       => 'kWh',
        'tariff'           => curve.key.to_s,
        'tariff_type'      => 'curve'
      }])
    end

    let!(:curve) do
      FactoryGirl.create(:price_curve_with_curve)
    end

    it 'assigns a CurveTariff to the relation' do
      node = les.node('hv')

      allow(node).to receive(:load).and_return([1] * 8760)
      allow(node).to receive(:energy_at).with(anything).and_return(0.0)
      allow(node).to receive(:energy_at).with(0).and_return(2.0)
      allow(node).to receive(:energy_at).with(1).and_return(2.0)

      rel  = market.node('system operator').out_edges.first
      rule = rel.rule

      expect(rule.call(rel)).to eq(12.0)
    end
  end # given a market model with a curve-based tariff
end
