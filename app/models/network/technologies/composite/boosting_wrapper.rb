module Network
  module Technologies
    module Composite
      # Wraps around boosting technologies which are used in the even that
      # buffering techs are insufficient to meet demand. They are not
      # constrained by the composite capacity, nor draw extra energy to be
      # stored for later use.
      class BoostingWrapper < Wrapper
        def mandatory_consumption_at(frame)
          if @composite.boosting_enabled_at?(frame)
            constrain_by_capacity(super)
          else
            0.0
          end
        end

        def conditional_consumption_at(frame)
          # Boosting technologies will never draw extra energy to fill up the
          # buffer; they satisfy whatever amount is needed to "boost" production
          # to meet demand and nothing more.
          0.0
        end
      end # BoostingWrapper
    end # Composite
  end
end
