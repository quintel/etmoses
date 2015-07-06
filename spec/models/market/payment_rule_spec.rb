require 'rails_helper'

module Market
  RSpec.describe PaymentRule do
    let(:market) do
      market   = Turbine::Graph.new

      customer = market.add(Stakeholder.new(:customer))
      retailer = market.add(Stakeholder.new(:retailer))
      producer = market.add(Stakeholder.new(:producer))

      producer.connect_to(retailer)
      retailer.connect_to(customer)

      market
    end

    context 'with a measurable of [1.0] and tariff of 2.0' do
      before { market.node(:customer).set(:measurables, [1.0]) }
      let(:rule) { PaymentRule.new(->(m) { m }, Tariff.new(2.0)) }

      context 'applied to a node one edge from the measurable' do
        let(:relation) { market.node(:retailer).out_edges.first }

        it 'has a price of 2.0' do
          expect(rule.call(relation)).to eq(2.0)
        end
      end

      context 'applied to a node two edges from the measurable' do
        let(:relation) { market.node(:producer).out_edges.first }

        it 'has a price of 2.0' do
          expect(rule.call(relation)).to eq(2.0)
        end
      end
    end # with a measurable of [1.0] and tariff of 2.0

    context 'with a foundation which returns an array' do
      before { market.node(:customer).set(:measurables, [1.0]) }
      let(:rule) { PaymentRule.new(->(m) { [m, m * 2] }, Tariff.new(2.0)) }

      context 'applied to a node one edge from the measurable' do
        let(:relation) { market.node(:retailer).out_edges.first }

        it 'prices each value' do
          expect(rule.call(relation)).to eq(6.0)
        end
      end

      context 'applied to a node two edges from the measurable' do
        let(:relation) { market.node(:producer).out_edges.first }

        it 'prices each value' do
          expect(rule.call(relation)).to eq(6.0)
        end
      end
    end # with a foundation which returns an array

    context 'with a per-unit foundation' do
      context 'and a measurable of [1.0, 2.0, 3.0] and tariff of 2.0' do
        let(:foundation) { PerUnitFoundation.new(->(m) { m }, ->(d) { 4 }) }
        let(:rule)       { PaymentRule.new(foundation, Tariff.new(2.0)) }
        let(:relation)   { market.node(:retailer).out_edges.first }

        before { market.node(:customer).set(:measurables, [1.0, 2.0, 3.0]) }

        it 'has has a price of 3.0' do
          # 2 * (tariff)
          #   (1.0 + 2.0 + 3.0) /
          #   4 (units)
          expect(rule.call(relation, [0, 1, 2])).to eq(3.0)
        end
      end # and a measurable of [1.0, 2.0, 3.0] and a tariff of 2.0
    end # with a per-unit foundation
  end
end
