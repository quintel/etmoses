class TestingGround
  class Concurrency
    def initialize(technologies)
      @technologies = JSON.parse(technologies)
    end

    def concurrensize
      TechnologyList.from_hash(grouped)
    end

    private

    def grouped
      TechnologyProfileScheme.new(concurrensized_technologies).to_h
    end

    def scheme
      TechnologyProfileScheme.new(@technologies).distribution
    end

    def concurrensized_technologies
      ConcurrensizedTechnologies.spread(scheme)
    end
  end
end
