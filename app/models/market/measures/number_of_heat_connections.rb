module Market::Measures
  # Determines how many heat connections are present on the given node.
  #
  # This number is defined as the largest of the number of installed units of
  # space heating and hot water composites.
  module NumberOfHeatConnections
    CONNECTION_TECHS = %w(
      households_space_heater_district_heating_steam_hot_water
      households_water_heater_district_heating_steam_hot_water
    ).freeze

    module_function

    def call(node, variants)
      heat_node = variants[:heat].call

      if heat_node && heat_node.get(:techs)
        count_with_technologies_list(heat_node.get(:techs).map(&:installed))
      else
        0
      end
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

    # Public: Given a technology profile from a LES, counts the total number of
    # heat connections in the LES.
    #
    # Returns an integer.
    def count_with_technology_profile(profile)
      profile.sum { |_key, techs| count_with_technologies_list(techs) }
    end

    def irregular?
      true
    end
  end
end
