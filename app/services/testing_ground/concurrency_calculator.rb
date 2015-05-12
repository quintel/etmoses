class TestingGround::ConcurrencyCalculator
  #
  # Creates a profile with a maximum/minimum concurrency from another profile
  #

  def initialize(profile, topology, differentiation = "max")
    @profile = JSON.parse(profile)
    @topology = JSON.parse(topology)
    @differentiation = differentiation
  end

  def calculate
    TestingGround::TechnologyProfileScheme.new(
      technologies, @topology, @differentiation
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
