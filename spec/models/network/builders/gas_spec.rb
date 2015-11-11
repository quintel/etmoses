require 'rails_helper'

module Network::Builders
  RSpec.describe Gas do
    let(:tree)     { { name: :a } }
    let(:graph)    { Gas.build(tree, list) }
    let(:techs)    { {} }
    let(:list)     { TechnologyList.from_hash(techs) }
    let(:endpoint) { graph.node(:a) }

    context 'when a node has a gas technology' do
      let(:techs) { { a: [{ carrier: :gas }] } }

      let(:list) do
        TechnologyList.from_hash(techs).tap do |list|
          expect(list[:a].first).to receive(:carrier).and_return(:gas)
        end
      end

      it 'has a "Gas Network" node' do
        expect(graph.node('Gas Network')).to be
      end

      it 'adds an endpoint node' do
        expect(endpoint).to be
      end

      it 'adds the gas technology' do
        expect(endpoint.get(:installed_techs).length).to eq(1)
      end

      it 'connects the endpoint to the global parent' do
        edges = endpoint.in_edges.to_a

        expect(edges.length).to eq(1)
        expect(edges.first.from).to eq(graph.node('Gas Network'))
      end
    end

    context 'when a node has a gas and electricity technology' do
      let(:techs) { { a: [{ carrier: :gas }, { carrier: :electricity }] } }

      let(:list) do
        TechnologyList.from_hash(techs).tap do |list|
          expect(list[:a].first).
            to receive(:carrier).at_least(:once).and_return(:gas)
        end
      end

      it 'has a "Gas Network" node' do
        expect(graph.node('Gas Network')).to be
      end

      it 'adds an endpoint node' do
        expect(endpoint).to be
      end

      it 'only adds the gas technology' do
        expect(endpoint.get(:installed_techs).map(&:carrier).uniq).to eq([:gas])
      end

      it 'connects the endpoint to the global parent' do
        edges = endpoint.in_edges.to_a

        expect(edges.length).to eq(1)
        expect(edges.first.from).to eq(graph.node('Gas Network'))
      end
    end

    context 'when a node has an electricity technology' do
      let(:techs) { { a: [{ carrier: :electricity }] } }

      it 'has a "Gas Network" node' do
        expect(graph.node('Gas Network')).to be
      end

      it 'does not have an endpoint node' do
        expect(endpoint).to_not be
      end
    end
  end # describe Gas
end # Network::Builders
