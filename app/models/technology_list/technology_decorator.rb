class TechnologyList
  class TechnologyDecorator
    def self.install(technology, profiles)
      new(technology, profiles).install
    end

    # technology is a Hash
    # profiles is a Hash of profiles
    def initialize(technology, profiles)
      @technology = technology
      @profiles   = profiles
    end

    def install
      InstalledTechnology.new(@technology.update(profile_attributes))
    end

    private

    def profile_attributes
      if profile_key && profile_id.blank?
        { 'profile' => @profiles.key(profile_key) }
      elsif profile_key.blank? && profile_id.try(:to_i)
        { 'profile_key' => @profiles[profile_id.to_i] }
      else
        {}
      end
    end

    def profile_id
      @technology['profile']
    end

    def profile_key
      @technology['profile_key']
    end
  end
end
