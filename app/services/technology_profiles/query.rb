module TechnologyProfiles
  class Query
    def initialize(distribution)
      @distribution = distribution
    end

    def query
      Hash[permits.group_by(&:technology).map do |tech_key, techs|
        [tech_key, techs.map { |tech| tech.load_profile.key }]
      end]
    end

    private

    def technology_keys
      @distribution.map{|t| t['type']}.uniq
    end

    def permits
      technology_profiles.map do |profile|
        if is_edsn_profile?(profile)
          profile.technology = 'base_load_edsn'
        end
        profile
      end
    end

    def is_edsn_profile?(profile)
      profile.technology == 'base_load' && profile.load_profile.is_edsn?
    end

    def technology_profiles
      TechnologyProfile.where(technology: technology_keys).includes(:load_profile)
    end
  end
end
