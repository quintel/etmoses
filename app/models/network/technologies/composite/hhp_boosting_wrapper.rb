module Network
  module Technologies
    module Composite
      # A special-case of BoostingWrapper used with the hybrid heat-pump
      # gas component.
      #
      # All HHP consumption is (currently) classed as conditional, therefore
      # we expect a non-zero load when boosting HHP consumption occurs.
      class HHPBoostingWrapper < Wrapper
        def mandatory_consumption_at(frame)
          0.0
        end

        def conditional_consumption_at(frame)
          @composite.boosting_enabled_at?(frame) ? super : 0.0
        end
      end # HHPBoostingWrapper
    end # Composite
  end
end
