module TechnologyProfiles
  class Query
    def initialize(distribution)
      @distribution = distribution
    end

    def query
      Hash[technology_profiles.map do |tech_key, technology_profiles|
        [ tech_key, technology_profiles.first.load_profile_id ]
      end]
    end

    private

    def technology_keys
      @distribution.map{|t| t['type']}.uniq
    end

    def technology_profiles
      TechnologyProfile.where(technology: technology_keys)
        .group_by(&:technology)
    end
  end
end
