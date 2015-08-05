module Network
  module Technologies
    # Describes a flexible technology whose loads may be postponed to a later
    # frame in order to avoid exceedances in network capacity.
    #
    # Loads which are deferred have an expiry date; if the network remains
    # congested up to this point, the load will be considered mandatory at that
    # time, and will be placed on the network without regard to available
    # capacity.
    #
    # Should the network congestion end prior to the deferred load expiry date,
    # the load will be applied as soon as possible.
    class DeferrableConsumer < Generic
      extend Disableable

      def self.disabled?(options)
        ! options[:postponing_base_load]
      end

      def self.disabled_class
        Generic
      end

      def initialize(*)
        super

        @capacity   = CapacityLimit.new(self)
      end

      def capacity_constrained?
        true
      end
    end # DeferrableConsumer
  end
end
