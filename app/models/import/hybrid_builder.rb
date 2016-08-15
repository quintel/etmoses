class Import
  class HybridBuilder < Builder
    include Filters
    # The hybrid expanders is a class that expands hybrid technologies.
    # It assumes the following:
    # - A hybrid consists out of a gas and electricity part
    # - The gas and electricity parts keys are the same as the parent key + '_gas' or
    #   '_electricity'.

    def build(response)
      response.select(&method(:hybrid?)).map do |hybrid|
        hybrid['components'] = hybrid_elements(hybrid)
        hybrid
      end
    end

    private

    def hybrid_elements(hybrid)
      Technology.find_by_key(hybrid.fetch('type')).components.map do |key|
        TechnologyBuilder.build(key, hybrid.slice('number_of_units'))
      end
    end
  end
end
