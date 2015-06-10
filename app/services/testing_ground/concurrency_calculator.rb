class TestingGround::ConcurrencyCalculator
  #
  # Creates a profile with a maximum/minimum concurrency from another profile
  #

  def initialize(technology_distribution, max_concurrency = true)
    @technology_distribution = JSON.parse(technology_distribution)
    @max_concurrency = max_concurrency
  end

  def calculate
    TestingGround::TechnologyProfileScheme.new(
      @technology_distribution, @max_concurrency
    ).build
  end
end
