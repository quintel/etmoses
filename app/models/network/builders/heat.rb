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
          must_run:         must_run,
          dispatchable:     dispatchable,
          # https://github.com/quintel/etmoses/issues/971
          volume:           number_of_connections * 10.0,
          amplified_volume: number_of_connections * 17.78
        )

        @graph = Graph.new(:heat)

        # TODO The global buffer technology needs to be added.
        @head = @graph.add(Node.new('Heat Network', {
          park: @park,
          stakeholder: 'heat producer',
          techs: [@park.buffer_tech],
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
        else
          techs = @techs[attrs[:name]].select { |t| t.carrier == :heat }

          return if techs.empty?

          @head.connect_to(@graph.add(
            Node.new(attrs[:name], {
              installed_techs: techs,
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

      # Internal: Given an array of InstalledHeatSources, creates the Producers
      # representing each one in the network calculation.
      #
      # Returns an array.
      def sources_to_producers(sources)
        sources.map do |source|
          curve = unless source.dispatchable?
            # TODO This is providing an uncut curve to the technology,
            # which means weekly calculations are always using Jan 1 to
            # Jan 7th.
            source.profile_curve.curves['default']
          end

          Network::Heat::Producer.new(source, curve, {})
        end
      end

      # Internal: Determines the total number of heat connections on the
      # endpoints.
      def number_of_connections
        @connections ||=
          @techs.sum do |_endpoint_name, endpoint_techs|
            Market::Measures::NumberOfHeatConnections
              .count_with_technologies_list(endpoint_techs)
          end
      end
    end # Heat
  end # Builders
end
