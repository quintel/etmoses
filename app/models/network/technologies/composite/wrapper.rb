module Network
  module Technologies
    module Composite
      # Wraps technologies which are part of a component to ensure that the
      # depleting profile is correctly adjusted for received energy.
      #
      # The delegator is based on Buffer, since it is the most complex of the
      # technologies modelled. This is not particularly future-proof: if another
      # technology is added with public methods not defined by Buffer, the
      # delegation will not work correctly (raising a NoMethodError).
      class Wrapper < FastDelegator.create(Buffer)
        attr_reader :object, :load

        def initialize(obj, composite)
          super(obj)
          @composite = composite
          @handle_decay = obj.respond_to?(:stored)
          @load = DefaultArray.new { 0.0 }
        end

        def production_at(frame)
          # Force evaluation of buffer decay.
          stored.at(frame) if @handle_decay
          super
        end

        def store(frame, amount)
          super
          receive_energy(frame, amount)
        end

        def receive_mandatory(frame, amount)
          super
          receive_energy(frame, amount)
        end

        # Public: Returns if the technology is a buffering technology. If false,
        # it is "boosting".
        #
        # Returns true or false.
        def buffering?
          false
        end

        # Public: Determines if the wrapper, or contained object, is an instance
        # of the given class.
        #
        # See Context#path_order.
        #
        # Returns true or false.
        def is_a?(klass)
          @object.is_a?(klass) || super
        end

        def inspect
          "#<#{ self.class.name } #{ @object.inspect }>"
        end

        private

        def constrain_by_capacity(amount)
          capacity = @object.capacity
          amount < capacity ? amount : capacity
        end

        # Internal: Takes care of assigning the energy received by the wrapper
        # and subtracting it from the profile as needed.
        def receive_energy(frame, amount)
          # Save the input load, unmodified by the performance coefficient which
          # is used to determine output.
          @load[frame] += amount

          output = amount * @object.installed.performance_coefficient
          profile.deplete(frame, output)

          output
        end
      end # Wrapper
    end # Composite
  end
end
