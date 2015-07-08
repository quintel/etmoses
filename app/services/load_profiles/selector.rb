module LoadProfiles
  # Given an array of technology keys which are to be imported from an ETEngine
  # scenario, retrieves the load profiles which may be used by those
  # technologies.
  #

  EDSN_THRESHOLD = 10

  class Selector
    # Public: Creates a ProfileSelector which selects profiles for the given
    # +technologies+ keys.
    def initialize(profiles, technology)
      @technology = technology
      @profiles   = selected_profiles(profiles)
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
        @technology["concurrency"] == 'min'
      end

      #
      # Selection of profiles is different for households due to the fact that EDSN
      # profiles are only picked when the units are above a certain threshold
      #
      def selected_profiles(profiles)
        profiles[(is_household? ? household_type : @technology['type'])]
      end

      def is_household?
        @technology['type'] == 'base_load'
      end

      def household_type
        (@technology['units'].to_i > EDSN_THRESHOLD ? 'base_load_edsn' : 'base_load')
      end
  end
end
