module Network
  module Builders
    # Takes a computed gas network and uses the loads to determine the flow
    # through a multi-level gas "chain" network. Each level in the chain is
    # connected with a optional capacity and efficiency constraints, which may
    # vary depending on the direction of flow.
    class GasChain
      GasNetwork = Struct.new(:forty, :eight, :four, :local)

      # Builds a gas chain network.
      #
      # For example
      #
      #   graph = testing_ground.to_calculated_graphs.detect do |net|
      #     net.carrier == :gas
      #   end
      #
      #   chain = Network::Builders::GasChain.build(graph)
      #
      #   # Gas load on the upper-most level in frame 0.
      #   chain[:upper].call(0)
      #
      #   # Gas load on the middle level in frame 10.
      #   chain[:middle].call(0)
      #
      # Contains four levels of the chain network; the 40-, 8-, 4-, and
      # 0.125-bar pressure levels. Beneath the lowest level is a single Source
      # which provides the total gas load in each frame. If the gas network is
      # empty, no Source is attached and the gas loads will always be zero.
      #
      # Returns a GasNetwork.
      def self.build(gas_network = Network::Graph.new(:gas), assets = [])
        new(gas_network, assets).to_network
      end

      # Public: Creates the gas chain network.
      #
      # Returns a Hash containing the chain levels.
      def to_network
        network = base_network

        if gas_head = @gas_network.head
          network.local.connect_to(lambda do |frame|
            gas_head.load[frame]
          end)
        end

        network
      end

      private

      def initialize(gas_network, assets)
        @gas_network = gas_network
        @assets      = assets
      end

      # Internal: Creates the basic chain network with three levels.
      #
      # Returns the network.
      def base_network
        network = GasNetwork.new(
          Chain::Layer.new, # 40-bar
          Chain::Layer.new, # 8-bar
          Chain::Layer.new, # 4-bar
          Chain::Layer.new  # 0.125-bar
        )

        connect(network.forty, network.eight, :eight)
        connect(network.eight, network.four,  :four)
        connect(network.four,  network.local, :local)

        network
      end

      # Internal: Given two `Component`s, connects them via a `Connection`.
      #
      # upper     - The higher-level chain component.
      # lower     - The lower-level chain component.
      # conn_args - The name of the lower-layer being connected.
      #
      # Returns the Connection.
      def connect(upper, lower, layer_name)
        connection = Chain::Connection.new(**Slots.build(layer_name, @assets))

        upper.connect_to(connection)
        connection.connect_to(lower)

        connection
      end
    end # GasChain
  end # Builders
end
