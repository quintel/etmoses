module Market::Measures
  # Determines how many heat connections are present on the given node.
  #
  # This number is defined as the largest of the number of installed units of
  # space heating and hot water composites.
  module NumberOfHeatConnections
    CONNECTION_TECHS = %w(buffer_space_heating buffer_water_heating).freeze

    module_function

    def call(node, variants)
      return 0 unless variants[:heat].call && node.get(:comps)

      count_with_technologies_list(node.get(:comps).map(&:installed))
    end

    # Public: Given a list of technologies attached to an endpoint, returns how
    # many heat connections the endpoint will have.
    #
    # Returns an Integer.
    def count_with_technologies_list(list)
      grouped = list.group_by(&:type)

      (CONNECTION_TECHS & grouped.keys).map do |type|
        grouped[type].sum { |installed| installed.units }.ceil
      end.max || 0
    end

    def irregular?
      true
    end
  end
end
