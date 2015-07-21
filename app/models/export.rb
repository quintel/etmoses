# Takes testing grounds and creates a full-size national scenario on ETEngine,
# based on the original scaled-down scenario and accounting for changes made in
# the testing ground.
class Export
  def initialize(testing_ground)
    @testing_ground = testing_ground
  end

  # Public: Creates a hash containing the inputs and values to be sent to
  # ETEngine in order to reflect the state of the testing ground.
  #
  # Returns a Hash.
  def inputs
    Hash[technology_units.map do |tech_key, units|
      [ Technology.by_key(tech_key).export_to,
        (units / factor_for_tech(tech_key) / number_of_households) * 100 ]
    end]
  end

  # Public: Sends requests to ETEngine in order to create the national scenario.
  #
  # Returns the JSON response body as a Hash.
  def export
    NationalScenarioCreator.new(@testing_ground, inputs).create
  end

  #######
  private
  #######

  # Private: Creates a hash desribing each technology and the number of units of
  # said technology in the testing ground.
  #
  # Each key is the key of a technology, and each value the number of units.
  #
  # Returns a Hash.
  def technology_units
    all_techs = @testing_ground.technology_profile.to_h.values.flatten
    count     = Hash.new { |hash, key| hash[key] = 0 }

    all_techs.each do |technology|
      count[technology.type] += technology.units
    end

    count.reject do |key, _|
      (! Technology.exists?(key: key)) ||
        Technology.by_key(key).export_to.blank?
    end
  end

  def factor_for_tech(tech_key)
    if tech_key == "households_solar_pv_solar_radiation"
      solar_panel_units_factor
    else
      1
    end
  end

  # Private: Queries ETEngine to determine the average amount of solar panels
  # for a single household
  #
  # Returns a Float
  def solar_panel_units_factor
    @solar_panel_units_factor ||= EtEngineConnector.new(gqueries: [
      'number_of_solar_pv'
    ]).gquery(@testing_ground.scenario_id)['future'] / number_of_households
  end

  # Private: Queries ETEngine to determine how many households exist in the
  # (scaled-down) scenario.
  #
  # Returns an Integer.
  def number_of_households
    @households ||= EtEngineConnector.new(gqueries: [
      'households_number_of_residences'
    ]).gquery(@testing_ground.scenario_id)['future']
  end
end
