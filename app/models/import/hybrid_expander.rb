class Import
  class HybridExpander
    # The hybrid expanders is a class that expands hybrid technologies.
    # It assumes the following:
    # - A hybrid consists out of a gas and electricity part
    # - The gas and electricity parts keys are the same as the parent key + '_gas' or
    #   '_electricity'.

    ELEMENTS = %w(electricity gas)

    def initialize(hybrids)
      @hybrids = hybrids
    end

    def expand
      @hybrids.inject([]) do |result, hybrid|
        result += hybrid_elements(hybrid)
      end
    end

    private

    def hybrid_elements(hybrid)
      ELEMENTS.map do |element|
        TechnologyBuilder.build(
          "#{ hybrid.fetch('type') }_#{ element }",
          units_attribute(hybrid.fetch('units'))
        )
      end
    end

    def units_attribute(units)
      { 'number_of_units' => { 'future' => units, 'present' => units } }
    end
  end
end
