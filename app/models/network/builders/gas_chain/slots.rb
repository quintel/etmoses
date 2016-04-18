module Network::Builders
  class GasChain
    # Given a gas asset list defined by a user, constructs the upward and
    # downward slots which will be used by a connection between layers.
    class Slots
      def self.build(layer, assets)
        new(layer, assets).build
      end

      # Creates a new Slots builder.
      #
      # layer  - The name of the child layer; the slots will be used on the
      #          connection between the child layer and its parent.
      # assets - An array containing all installed assets.
      #
      # Returns a Slots builder.
      def initialize(layer, assets)
        @layer = layer

        @assets = assets.select do |asset|
          asset.part == 'connectors'.freeze &&
          asset.pressure_level_name == layer
        end
      end

      # Public: Constructs the slots to be used by the Connection.
      #
      # Returns a hash with :upward and :downward keys.
      def build
        return default_slots if @assets.empty?

        { upward:   Network::Chain::Slot.upward(**attributes('low_to_high')),
          downward: Network::Chain::Slot.downward(**attributes('high_to_low')) }
      end

      private

      # Internal: Calculated the total capacity and net efficiency in the chosen
      # direction.
      #
      # Returns a hash with :capacity and :efficiency.
      def attributes(direction)
        capacity = total_capacity(direction)

        efficiency = @assets.sum do |asset|
          asset_capacity = capacity_of(asset, direction)

          if asset_capacity > 0
            asset.part_record.efficiency[direction] *
              (asset_capacity / capacity)
          else
            0.0
          end
        end

        { capacity: capacity, efficiency: efficiency }
      end

      # Internal: Determines the total connection capacity in the given
      # direction.
      #
      # Returns a numeric.
      def total_capacity(direction)
        @assets.sum { |asset| capacity_of(asset, direction) }
      end

      # Internal: Given a connector and direction, returns the capacity of the
      # part.
      #
      # Returns a numeric.
      def capacity_of(asset, direction)
        asset.part_record.capacity[direction] * asset.amount
      end

      # Internal: If the user did not define any connections between the layers,
      # the default slots are used.
      #
      # Returns a hash.
      def default_slots
        { upward:   Network::Chain::Slot.upward,
          downward: Network::Chain::Slot.downward }
      end
    end
  end # Builders
end
