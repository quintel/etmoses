class TestingGround
  class Concurrency
    module Maximizer
      def maximize
        -> (techs) do
          tech       = techs.first
          tech.units = techs.sum(&:units)
          tech
        end
      end
    end
  end
end
