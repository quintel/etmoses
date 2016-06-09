require_relative '../builders'

module Network
  module Builders
    class Heat
      def self.build(tree, techs = TechnologyList.new, heat_sources = nil)
        new(
          tree, techs,
          heat_sources ? HeatSourceListDecorator.new(heat_sources).decorate : []
        ).to_graph
      end

      def to_graph
        @graph || build_graph
      end

      private

      def initialize(tree, techs, heat_sources)
        @tree         = tree
        @techs        = techs
        @heat_sources = heat_sources
      end

      def build_graph
        # TODO Create production park on installed techs.
        dispatchable, must_run =
          sources_to_producers(@heat_sources).partition(&:dispatchable?)

        @park = Network::Heat::ProductionPark.new(
          must_run:     must_run,
          dispatchable: dispatchable,
          volume:       1.0 # TODO ???
        )

        @graph = Graph.new(:heat)

        # TODO The global buffer technology needs to be added.
        @head = @graph.add(Node.new('Heat Network', {
          park: @park,
          stakeholder: 'heat producer',
          installed_techs: []
        }))

        build_node(@tree, nil)

        @graph
      end

      def build_node(attrs, parent = nil)
        attrs    = attrs.symbolize_keys
        children = attrs.delete(:children)

        return unless valid_node?(attrs)

        # TODO Install endpoints for any elec. network endpoint with a
        # composite. All composites are heat, right? :/
        #
        # On each endpoint, create an InstalledTechnology which will turn into
        # a heat consumer in TechnologyLoad.
        if children && children.any?
          children.each { |child| build_node(child) }
        elsif (composites = @techs[attrs[:name]].select(&:composite)).any?
          @head.connect_to(@graph.add(
            Node.new(attrs[:name], {
              installed_techs: consumers_for(composites),
              installed_comps: []
            })
          ))
        end
      end

      # Internal: Determines if the given node attributes are sufficient to add a
      # new node to the graph.
      def valid_node?(attrs)
        attrs.key?(:name) || attrs.key?('name'.freeze)
      end

      # Internal: Given a list of heat composites which exist on the endpoint,
      # creates a new InstalledTechnology to represent an endpoint consumer
      # technology which will attempt to satisfy demand using the heat
      # production park.
      #
      # Returns an array.
      def consumers_for(composites)
        composites.map do |comp|
          InstalledTechnology.new(
            type:     'heat_consumer',
            behavior: 'heat_consumer',
            buffer:   comp.composite_value
          )
        end
      end

      # Internal: Given an array of InstalledHeatSources, creates the Producers
      # representing each one in the network calculation.
      #
      # Returns an array.
      def sources_to_producers(sources)
        sources.map do |source|
          Network::Heat::Producer.new(
            source, source.dispatchable? ? nil : source.network_curve, {}
          )
        end
      end
    end # Heat
  end # Builders
end
