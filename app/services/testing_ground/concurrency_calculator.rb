class TestingGround::ConcurrencyCalculator
  #
  # Creates a profile with a maximum/minimum concurrency from another profile
  #

  def initialize(profile, topology, max_concurrency = true)
    @profile = JSON.parse(profile)
    @topology = JSON.parse(topology)
    @max_concurrency = max_concurrency
  end

  def calculate
    TestingGround::TechnologyProfileScheme.new(
      technologies, @topology, @max_concurrency
    ).build
  end

  private

    #
    # Extracts all unique technologies from a profile and sums the units
    #
    def technologies
      grouped_technologies.values.map do |technologies|
        technologies[0]['units'] = technologies.sum{|t| t['units'].to_i }
        technologies[0].delete('node')
        technologies[0]
      end
    end

    def grouped_technologies
      @profile.values.flatten.group_by do |technology|
        technology['type']
      end
    end
end
