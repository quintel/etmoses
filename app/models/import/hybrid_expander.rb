class Import
  class HybridExpander
    # The hybrid expanders is a class that expands hybrid technologies.
    # It assumes the following:
    # - A hybrid consists out of a gas and electricity part
    # - The gas and electricity parts keys are the same as the parent key + '_gas' or
    #   '_electricity'.

    def initialize(hybrids)
      @hybrids = hybrids
    end

    def expand
      @hybrids.inject([]) do |result, hybrid|
        result += parts(hybrid)
      end
    end

    private

    def parts(hybrid)
      %w(electricity gas).map do |hybrid_part|
        TechnologyBuilder.build(
          "#{ hybrid.fetch('type') }_#{ hybrid_part }", data_for_part(hybrid)
        )
      end
    end

    def data_for_part(hybrid)
      { 'number_of_units' => {
          'future'  => hybrid.fetch('units'),
          'present' => hybrid.fetch('units')
      } }
    end
  end
end
