class Import
  class BaseBuilder
    def initialize(gqueries, id:, scaling:, **)
      @gqueries    = gqueries
      @scenario_id = id
      @scaling     = scaling
    end

    def build(_response)
      fail NotImplementedError, <<-eos
        Every sub-class of Builder needs a method called 'build'
      eos
    end

    private

    def number_of_residences
      if query = @gqueries['number_of_residences']
        query.fetch("future")
      else
        0
      end
    end
  end
end
