require 'rails_helper'

RSpec.describe Market::Graph do
  let(:market) do
    market   = Market::Graph.new

    node_one = market.add(Market::Stakeholder.new(:a))
    node_two = market.add(Market::Stakeholder.new(:b))

    node_one.connect_to(node_two, :left)
    node_one.connect_to(node_two, :right)
    node_two.connect_to(node_one, :right)

    market
  end

  describe '#relations' do
    it 'returns all edges in the graph' do
      expect(market.relations.length).to eq(3)

      market.nodes.each do |node|
        node.out_edges.each do |edge|
          expect(market.relations).to include(edge)
        end
      end
    end
  end # #relations
end
