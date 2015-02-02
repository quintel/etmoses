require 'rails_helper'

RSpec.describe TreeToGraph do
  let(:graph) { TreeToGraph.convert(tree, techs) }
  let(:techs) { {} }

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

    it 'sets the load to zero' do
      expect(graph.node(:a).get(:load)).to eq(Rational('0'))
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
    let(:tree) { { name: :a } }

    context 'and both technologies have a positive load' do
      let(:techs) { { a: [{ load: 1.1 }, { load: 2.3 }] } }

      it 'sets a load attribute' do
        expect(graph.node(:a).get(:load)).to eq(Rational('3.4'))
      end
    end

    context 'and one technology has a negative load' do
      let(:techs) { { a: [{ load: 1.1 }, { load: -2.3 }] } }

      it 'sets a load attribute' do
        expect(graph.node(:a).get(:load)).to eq(Rational('-1.2'))
      end
    end

    context 'and one technology has an undefined load' do
      let(:techs) { { a: [{ load: 1.1 }, {}] } }

      it 'assumes the undefined load is zero' do
        expect(graph.node(:a).get(:load)).to eq(Rational('1.1'))
      end
    end

    context 'and a technology defines load as a numeric string' do
      let(:techs) { { a: [{ load: 1.1 }, { load: '2.3' }] } }

      it 'sets a load attribute' do
        expect(graph.node(:a).get(:load)).to eq(Rational('3.4'))
      end
    end

    context 'and a technology defines load as a non-numeric string' do
      let(:techs) { { a: [{ load: 1.1 }, { load: 'nope' }] } }

      it 'assumes the non-numeric load is zero' do
        expect(graph.node(:a).get(:load)).to eq(Rational('1.1'))
      end
    end
  end # when a node has two attached technologies
end # describe TreeToGraph
