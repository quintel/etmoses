class TestingGround::ConcurrencyCalculator
  def initialize(profile, differentiation = "max")
    @profile = JSON.parse(profile)
    @differentiation = differentiation
  end

  def calculate
    @profile.each_pair do |node, technologies|
      technologies.each_with_index.map do |technology|
        technology['profile'] = select_profile(technology)
        technology
      end
    end
  end

  private

    def index(technology)
      all_technologies.index(technology)
    end

    def select_profile(technology)
      profile_selector.select_profile(technology['type'], index(technology))
    end

    def profile_selector
      @profile_selector ||= Import::ProfileSelector.new(technology_keys, @differentiation)
    end

    def technology_keys
      all_technologies.map do |technology|
        technology['type']
      end.uniq
    end

    def all_technologies
      @profile.values.flatten.sort do |technology_a, technology_b|
        technology_a['type'] <=> technology_b['type']
      end
    end
end
