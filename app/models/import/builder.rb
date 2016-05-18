class Import
  class Builder
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
  end
end
