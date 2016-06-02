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
        @layer  = layer
        @assets = assets.select(&method(:asset_predicate)).group_by(&:direction)
      end

      # Public: Constructs the slots to be used by the Connection.
      #
      # Returns a hash with :upward and :downward keys.
      def build
        return default_slots if @assets.empty?

        { upward:   Network::Chain::Slot.upward(**attributes(:upward)),
          downward: Network::Chain::Slot.downward(**attributes(:downward)) }
      end

      private

      # Internal: Calculated the total capacity and net efficiency in the chosen
      # direction.
      #
      # Returns a hash with :capacity and :efficiency.
      def attributes(direction)
        capacity   = total_capacity(direction)
        efficiency = 0.0

        # No assets installed?
        return { capacity: Float::INFINITY, efficiency: 1.0 } if capacity.nil?

        (@assets[direction] || []).each do |asset|
          asset_capacity   = capacity_of(asset)
          asset_efficiency = asset.part_record.efficiency || 1.0

          if asset_capacity == Float::INFINITY
            # This asset dominates the slot so we set efficiency equal to this
            # component and call it a day.
            efficiency = asset_efficiency
            break
          elsif asset_capacity > 0
            efficiency += asset_efficiency * (asset_capacity / capacity)
          end
        end

        { capacity: capacity, efficiency: efficiency }
      end

      # Internal: Determines the total connection capacity in the given
      # direction.
      #
      # Returns a numeric.
      def total_capacity(direction)
        return unless @assets[direction]

        @assets[direction].sum { |asset| capacity_of(asset) }
      end

      # Internal: Given a connector and direction, returns the capacity of the
      # part.
      #
      # Returns a numeric.
      def capacity_of(asset)
        part = asset.part_record
        part.capacity ? part.capacity * asset.amount : Float::INFINITY
      end

      # Internal: If the user did not define any connections between the layers,
      # the default slots are used.
      #
      # Returns a hash.
      def default_slots
        { upward:   Network::Chain::Slot.upward,
          downward: Network::Chain::Slot.downward }
      end

      def asset_predicate(asset)
        (asset.direction == :upward || asset.direction == :downward) &&
          asset.pressure_level_name == @layer &&
          asset.amount > 0
      end
    end
  end # Builders
end
