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

      # Describes a load which has been deferred from a frame where there was
      # insufficient capacity available on the network. `mandatory_at` describes
      # the frame by which the load MUST be applied.
      DeferrableLoad = Struct.new(:amount, :mandatory_at)

      def self.disabled?(options)
        !options[:postponing_base_load]
      end

      def self.disabled_class
        Generic
      end

      def initialize(*)
        super

        @deferreds  = []
        @last_frame = @profile.length - 1
        @capacity   = CapacityLimit.new(self)
      end

      def capacity_constrained?
        true
      end

      # Public: The amount of energy which must be satisfied in the given frame.
      # Deferred loads become mandatory upon reaching their expiry date, or the
      # final frame of the calculation: whichever occurs first.
      #
      # Returns a numeric.
      def mandatory_consumption_at(frame)
        if frame == @last_frame
          return @deferreds.sum(&:amount) + @profile.at(frame)
        end

        defer = @deferreds.detect do |deferred|
          # Deferreds are ordered by their mandatory_at value; if deferred
          # occurs after the given frame, we can return early.
          return 0.0 if deferred.mandatory_at > frame

          deferred.mandatory_at == frame
        end

        defer ? defer.amount : 0.0
      end

      # Public: All non-deferred loads, and deferred load not yet at their
      # expiry date, are considered conditional.
      #
      # Returns a numeric.
      def conditional_consumption_at(frame)
        # All loads are mandatory in the final frame.
        return 0.0 if frame == @last_frame

        @capacity.limit_conditional(
          frame,
          @profile.at(frame) +
            @deferreds.sum { |d| d.mandatory_at == frame ? 0.0 : d.amount }
        )
      end

      # Public: Informs the Deferrable that some or all of its conditional
      # consumption has been satisfied.
      #
      # Returns nothing.
      def store(frame, amount)
        @deferreds.delete_if { |deferred| deferred.mandatory_at == frame }

        if @deferreds.any?
          # If there are any deferred loads waiting to be satisfied; reduce
          # their loads first, before satisfying the demands of the current
          # frame.
          amount = reduce_deferred!(amount)
        end

        if amount <= @profile.at(frame)
          # When there is unsatisfied load, we have to defer it until later.
          defer!(frame, @profile.at(frame) - amount)
        end
      end

      #######
      private
      #######

      def defer!(frame, amount)
        return if amount.zero?

        mandatory_at = @last_frame < (frame + 12) ? @last_frame : (frame + 12)
        @deferreds.push(DeferrableLoad.new(amount, mandatory_at))
      end

      def reduce_deferred!(amount)
        @deferreds.each do |deferred|
          if amount <= 0
            break
          elsif amount < deferred.amount
            # Not enough energy to satisfy the deferred completely. Reduce the
            # wanted amount and stop.
            deferred.amount -= amount
            amount = 0.0
            break
          else
            amount -= deferred.amount
            deferred.amount = 0.0
          end
        end

        @deferreds.delete_if { |deferred| deferred.amount <= 0 }

        amount
      end
    end # DeferrableConsumer
  end
end
