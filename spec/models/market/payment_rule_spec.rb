require 'rails_helper'

module Market
  RSpec.describe PaymentRule do
    let(:market) do
      market   = Turbine::Graph.new

      customer = market.add(Stakeholder.new(:customer))
      retailer = market.add(Stakeholder.new(:retailer))
      producer = market.add(Stakeholder.new(:producer))

      customer.connect_to(retailer)
      retailer.connect_to(producer)

      market
    end

    context 'with a measurable of [1.0] and tariff of 2.0' do
      let(:rule) { PaymentRule.new(->(m) { m }, Tariff.new(2.0)) }
      let(:relation) { market.node(:retailer).in_edges.first }

      before { relation.set(:measurables, [1.0]) }

      it 'has a price of 2.0' do
        expect(rule.call(relation)).to eq(2.0)
      end
    end # with a measurable of [1.0] and tariff of 2.0

    context 'with a measurable of [-1.0] and tariff of 2.0' do
      let(:rule) { PaymentRule.new(->(m) { m }, Tariff.new(2.0)) }
      let(:relation) { market.node(:retailer).in_edges.first }

      before { relation.set(:measurables, [-1.0]) }

      it 'has a price of 0.0' do
        expect(rule.call(relation)).to eq(0.0)
      end
    end # with a measurable of [-1.0] and tariff of 2.0

    context 'with a measure which returns an array' do
      let(:rule) { PaymentRule.new(->(m) { [m, m * 2] }, Tariff.new(2.0)) }
      let(:relation) { market.node(:retailer).in_edges.first }

      before { relation.set(:measurables, [1.0]) }

      it 'prices each value' do
        expect(rule.call(relation)).to eq(6.0)
      end
    end # with a measure which returns an array

    context 'with a per-unit measure' do
      context 'and a measurable of [1.0, 2.0, 3.0] and tariff of 2.0' do
        let(:measure)  { PerUnitMeasure.new(->(m) { m }, ->(d) { 4 }) }
        let(:rule)     { PaymentRule.new(measure, Tariff.new(2.0)) }
        let(:relation) { market.node(:retailer).in_edges.first }

        before { relation.set(:measurables, [1.0, 2.0, 3.0]) }

        it 'has has a price of 3.0' do
          # 2 * (tariff)
          #   (1.0 + 2.0 + 3.0) /
          #   4 (units)
          expect(rule.call(relation, [0, 1, 2])).to eq(3.0)
        end
      end # and a measurable of [1.0, 2.0, 3.0] and a tariff of 2.0
    end # with a per-unit measure

    context 'with variants' do
      let(:rule) { PaymentRule.new(measure, Tariff.new(2.0)) }
      let(:relation) { market.node(:retailer).in_edges.first }
      let(:variants) { { other: ->*{ ->{ 4.0 } } } }

      before { relation.set(:measurables, [1.0]) }

      context 'and a measure with arity=1' do
        let(:measure) { ->(m) { m } }

        it 'has a price of 2.0' do
          expect(rule.call(relation, variants)).to eq(2.0)
        end
      end

      context 'and a measure with arity=2' do
        let(:measure) { ->(m, variants) { m * variants[:other].call } }

        it 'sends the variant to the measure' do
          expect(rule.call(relation, variants)).to eq(8.0)
        end
      end
    end # with variants
  end
end
