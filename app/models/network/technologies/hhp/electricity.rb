module Network
  module Technologies
    module HHP
      class Electricity < Base
        def initialize(installed, profile,
                       behavior_profile:,
                       hhp_switch_to_gas: false,
                       **)
          super

          @behavior_profile     = behavior_profile
          @capacity_constrained = hhp_switch_to_gas
        end

        def conditional_consumption_at(frame)
          if @behavior_profile && ! @behavior_profile.at(frame).zero?
            0.0
          else
            super
          end
        end

        def capacity_constrained?
          @capacity_constrained
        end
      end # Electricity
    end # HHP
  end
end
