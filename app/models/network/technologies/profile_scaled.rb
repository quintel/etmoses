module Network
  module Technologies
    module ProfileScaled
      def build(*)
        instance = super
        instance.is_a?(Storage) ? Delegator.new(instance) : instance
      end

      # Wraps around a (storage) technology so that the technology need not
      # worry about the resolution of its profile. The technology may treat all
      # values, and stored amounts, as being in the same unit and doesn't have
      # to perform conversions between kW and kWh (which vary depending on the
      # profile resolution).
      class Delegator < SimpleDelegator
        TO_KW_METHODS = %i(
          load_at
          production_at
          conditional_consumption_at
          mandatory_consumption_at
        ).freeze

        def initialize(technology)
          super
          @technology = technology

          @to_kw  = technology.profile.length.to_f / 8760
          @to_kwh = 1 / @to_kw
        end

        TO_KW_METHODS.each do |meth|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{ meth }(*args)
              @technology.#{ meth }(*args) * @to_kw
            end
          RUBY
        end

        # Public: Tells the technology to store the given "load" for future use.
        # We convert the load to kWh depending on the resolution of the profile.
        def store(frame, amount)
          @technology.store(frame, amount * @to_kwh)
        end
      end # Delegator
    end # ProfileScaled
  end
end
