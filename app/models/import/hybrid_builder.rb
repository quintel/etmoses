class Import
  class HybridBuilder < Builder
    include Filters
    # The hybrid expanders is a class that expands hybrid technologies.
    # It assumes the following:
    # - A hybrid consists out of a gas and electricity part
    # - The gas and electricity parts keys are the same as the parent key + '_gas' or
    #   '_electricity'.

    CARRIERS = %w(electricity gas)

    def build(response)
      response
        .select(&method(:hybrid?))
        .flat_map(&method(:hybrid_elements))
    end

    private

    def hybrid_elements(hybrid)
      CARRIERS.map do |carrier|
        TechnologyBuilder.build(
          "#{ hybrid.fetch('type') }_#{ carrier }",
          units_attribute(hybrid.fetch('units'))
        )
      end
    end

    def units_attribute(units)
      {
        'number_of_units' => { 'future' => units, 'present' => units }
      }
    end
  end
end
