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
end # describe Topology
