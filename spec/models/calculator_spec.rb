require 'rails_helper'

RSpec.describe Calculator do
  let(:graph) do
    graph = Turbine::Graph.new

    graph.add(source)
    graph.add(parent)
    graph.add(uncle)
    graph.add(child1)
    graph.add(child2)

    source.connect_to(parent, :energy)
    source.connect_to(uncle,  :energy)
    parent.connect_to(child1, :energy)
    parent.connect_to(child2, :energy)

    graph
  end

  let(:source) { Turbine::Node.new(:source) }
  let(:parent) { Turbine::Node.new(:parent) }
  let(:uncle)  { Turbine::Node.new(:uncle,  load:  0.1) }
  let(:child1) { Turbine::Node.new(:child1, load: -1.1) }
  let(:child2) { Turbine::Node.new(:child2, load:  3.2) }

  let(:cgraph) do
    Calculator.calculate(graph)
  end

  it 'calculates nodes whose descendants are initialized with a load' do
    expect(cgraph.node(:parent).get(:load)).to eq(2.1)
  end

  it 'calculates nodes whose descendant load is not initially known' do
    expect(cgraph.node(:source).get(:load)).to eq(2.2)
  end
end # Calculator
