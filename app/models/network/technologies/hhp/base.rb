module Network
  module Technologies
    module HHP
      class Base < Buffer
        alias_method :conditional_consumption_at, :mandatory_consumption_at

        # Public: Mandatory consumption is disabled for hybrid heat-pumps due to
        # the fact that the production of the electrical component is contrained
        # by network capacity only.
        def mandatory_consumption_at(_frame)
          0.0
        end

        def excess_constrained?
          false
        end

        def capacity_constrained?
          true
        end

        def store(frame, amount)
          # Do nothing; don't store anything in the reserve.
        end

        alias_method :receive_mandatory, :store
      end # Base
    end # HHP
  end
end
