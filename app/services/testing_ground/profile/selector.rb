class TestingGround
  module Profile
    # Given an array of technology keys which are to be imported from an ETEngine
    # scenario, retrieves the load profiles which may be used by those
    # technologies.
    #
    class Selector
      # Public: Creates a ProfileSelector which selects profiles for the given
      # +technologies+ keys.
      def initialize(profiles, technology)
        @profiles    = profiles[technology['type']]
        @concurrency = technology['concurrency']
      end

      def select_profile
        minimize_concurrency? ? for_tech.next : first
      end

      def size
        minimize_concurrency? && @profiles ? @profiles.size : 1
      end

      private

        def for_tech
          Enumerator.new do |yielder|
            tech_profiles = (@profiles || [])

            loop do
              element = tech_profiles.shift
              tech_profiles.push(element)

              yielder.yield(element)
            end
          end
        end

        def first
          @profiles.try(:first)
        end

        def minimize_concurrency?
          @concurrency == 'min'
        end
    end
  end
end
