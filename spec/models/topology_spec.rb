require 'rails_helper'

RSpec.describe Topology do
  context 'with symbol graph keys' do
    it 'requires the root node to have a name' do
      topology = Topology.new(graph: { name: '' })
      expect(topology.errors_on(:graph)).to include("has an unnamed component")
    end

    it 'requires each child node to have a name' do
      topology = Topology.new(graph: { name: 'Top', children: [{}] })
      expect(topology.errors_on(:graph)).to include("has an unnamed component")
    end

    it 'requires each node to have a unique name' do
      topology = Topology.new(graph: {
        name: 'Top', children: [{ name: 'Top' }]
      })

      expect(topology.errors_on(:graph)).
        to include('has a duplicate component: "Top"')
    end
  end # with symbol graph keys

  context 'with string graph keys' do
    it 'requires the root node to have a name' do
      topology = Topology.new(graph: { 'name' => '' })
      expect(topology.errors_on(:graph)).to include("has an unnamed component")
    end

    it 'requires each child node to have a name' do
      topology = Topology.new(graph: { 'name' => 'Top', 'children' => [{}] })
      expect(topology.errors_on(:graph)).to include("has an unnamed component")
    end

    it 'requires each node to have a unique name' do
      topology = Topology.new(graph: {
        'name' => 'Top', 'children' => [{ 'name' => 'Top' }]
      })

      expect(topology.errors_on(:graph)).
        to include('has a duplicate component: "Top"')
    end
  end # with symbol graph keys

  context 'with a node containing a "units" attribute' do
    let(:topology) { Topology.new(name: "Topology",
                                  graph: { name: 'A', units: 1.0 }) }

    it 'allows "units" to be zero' do
      topology.graph['units'] = 0.0
      expect(topology).to be_valid
    end

    it 'allows "units" to be 1.5' do
      topology.graph['units'] = 1.5
      expect(topology).to be_valid
    end

    it 'disallows "units" to be less than zero' do
      topology.graph['units'] = -1.0

      expect(topology.errors_on(:graph)).
        to include('may not have a node with "units" less than zero: "A"')
    end

    it 'disallows "units" to be a string' do
      topology.graph['units'] = '1.0'

      expect(topology.errors_on(:graph)).
        to include('may not have a non-numeric "units" attribute')
    end
  end # with a node containing a "units" attribute
end # describe Topology
