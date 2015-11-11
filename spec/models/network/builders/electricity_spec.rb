require 'rails_helper'

module Network::Builders
  RSpec.describe Electricity do
    let(:graph) { Electricity.build(tree, list) }
    let(:techs) { {} }
    let(:list)  { TechnologyList.from_hash(techs) }

    context 'with nil' do
      let(:tree) { nil }

      it 'creates an empty graph' do
        expect(graph.nodes).to be_empty
      end
    end # with nil

    context 'with an empty tree' do
      let(:tree) { Hash.new }

      it 'creates an empty graph' do
        expect(graph.nodes).to be_empty
      end
    end # an empty tree

    context 'with a single node' do
      let(:tree) { { name: :a } }

      it 'creates the node' do
        expect(graph.node(:a)).to be
      end
    end # with a single node

    context 'when a node has no children' do
      let(:tree) { { name: :a } }

      it 'sets no technologies' do
        expect(graph.node(:a).get(:installed_techs)).to eq([])
      end
    end # when a node has no children

    context 'with a parent and two children' do
      let(:tree) {{
        name: :parent,
        children: [{ name: :child1 }, { name: :child2 }]
      }}

      it 'creates the parent' do
        expect(graph.node(:parent)).to be
      end

      context 'the first child' do
        it 'exists' do
          expect(graph.node(:child1)).to be
        end

        it 'is connected to the parent' do
          edge = graph.node(:child1).in_edges.first

          expect(edge).to be
          expect(edge.from).to eq(graph.node(:parent))
        end
      end

      context 'the second child' do
        it 'exists' do
          expect(graph.node(:child2)).to be
        end

        it 'is connected to the parent' do
          edge = graph.node(:child2).in_edges.first

          expect(edge).to be
          expect(edge.from).to eq(graph.node(:parent))
        end
      end
    end # with a parent and two children

    context 'when a node has two attached technologies' do
      let(:tree)  { { name: :a } }
      let(:techs) { { a: [{ load: 1.1 }, { load: 2.3 }] } }

      it 'sets both technologies' do
        expect(graph.node(:a).get(:installed_techs).length).to eq(2)
      end
    end # when a node has two attached technologies

    context 'when a node has a gas technology' do
      let(:tree)  { { name: :a } }
      let(:techs) { { a: [{ carrier: :gas }] } }

      let(:list) do
        TechnologyList.from_hash(techs).tap do |list|
          expect(list[:a].first).to receive(:carrier).and_return(:gas)
        end
      end

      it 'does not add the gas technology' do
        expect(graph.node(:a).get(:installed_techs)).to be_empty
      end
    end
  end # describe Electricity
end # Network::Builders
