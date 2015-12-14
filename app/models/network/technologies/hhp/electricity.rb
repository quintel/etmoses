module Network
  module Technologies
    module HHP
      class Electricity < Base
        def initialize(installed, profile, options)
          super
          @behavior_profile = options[:behavior_profile]
        end

        def conditional_consumption_at(frame)
          if @behavior_profile && @behavior_profile.at(frame).zero?
            0.0
          else
            super
          end
        end
      end # Electricity
    end # HHP
  end
end
