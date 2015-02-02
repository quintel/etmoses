require 'rails_helper'

RSpec.describe GraphToTree do
  let(:tree)  { GraphToTree.convert(graph) }
  let(:graph) { Turbine::Graph.new }

  context 'with a parent and two children' do
    before do
      parent = graph.add(Turbine::Node.new(:parent))
      child1 = graph.add(Turbine::Node.new(:child1))
      child2 = graph.add(Turbine::Node.new(:child2))

      parent.connect_to(child1, :energy)
      parent.connect_to(child2, :energy)
    end

    it 'creates the parent as the root' do
      expect(tree).to include(name: :parent)
    end

    it 'creates the first child' do
      expect(tree[:children]).to include(a_hash_including(name: :child1))
    end

    it 'creates the second child' do
      expect(tree[:children]).to include(a_hash_including(name: :child2))
    end
  end # with a parent and two children

  context 'with a node containing a load' do
    before do
      graph.add(Turbine::Node.new(:a, load: Rational('1.3')))
    end

    it 'converts the load to a float' do
      expect(graph.node(:a).get(:load)).to eq(1.3)
    end
  end # with a node containing a load

  context 'with a node containing no load' do
    before do
      graph.add(Turbine::Node.new(:a))
    end

    it 'converts the load to a float' do
      expect(graph.node(:a).get(:load)).to be_nil
    end
  end # with a node containing no load
end # describe GraphToTree
