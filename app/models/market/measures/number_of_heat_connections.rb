module Market::Measures
  # Determines how many heat connections are present on the given node.
  #
  # This number is defined as the largest of the number of installed units of
  # space heating and hot water composites.
  module NumberOfHeatConnections
    CONNECTION_TECHS = %w(buffer_space_heating buffer_water_heating).freeze

    def self.call(node, variants)
      return 0 unless variants[:heat].call && node.get(:comps)

      grouped = node.get(:comps).map(&:installed).group_by(&:type)

      (CONNECTION_TECHS & grouped.keys).map do |type|
        grouped[type].sum { |installed| installed.units }
      end.max || 0
    end

    def self.irregular?
      true
    end
  end
end
