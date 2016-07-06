module TechnologyProfiles
  class Query
    def initialize(distribution)
      @distribution = distribution
    end

    def query
      Hash[permits.group_by(&:technology).map do |tech_key, techs|
        [ tech_key, techs.select(&method(:included_in_concurrency?))
                         .map(&:load_profile_id) ]
      end]
    end

    private

    def technology_keys
      @distribution.map(&:type).uniq
    end

    def included_in_concurrency?(tech)
      tech.load_profile.included_in_concurrency?
    end

    def permits
      TechnologyProfile.where(technology: technology_keys)
        .includes(:load_profile)
    end
  end
end
