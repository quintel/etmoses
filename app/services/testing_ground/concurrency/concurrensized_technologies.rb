class TestingGround
  class Concurrency
    class ConcurrensizedTechnologies
      include ProfileSelector

      #
      # Expands the technology distribution depending on a technology's
      # concurrency setting and amount of profiles
      #

      def self.spread(technologies)
        new(technologies).spread.flatten
      end

      def initialize(technologies)
        @technologies = technologies
      end

      def spread
        TechnologyConnector.connect(@technologies).map do |tech|
          TechnologyPartitioner.new(tech, profile_selector(tech).size)
            .partition.map(&method(:set_profile))
        end
      end

      private

      def set_profile(technology)
        technology.profile = profile_selector(technology).select_profile
        technology
      end
    end
  end
end
