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
    Hash[technology_units.map do |technology, units|
      value = (units / factor_for_tech(technology.key) / number_of_households) * 100

      [technology, limit_value(value, technology.export_to)]
    end]
  end

  # Public: Sends requests to ETEngine in order to create the national scenario.
  #
  # Returns the JSON response body as a Hash.
  def export
    NationalScenarioCreator.new(@testing_ground, inputs).create
  end

  private

  # Private: Creates a hash desribing each technology and the number of units of
  # said technology in the testing ground.
  #
  # Each key is the key of a technology, and each value the number of units.
  #
  # Returns a Hash.
  def technology_units
    @testing_ground.technology_profile.to_h.values.flatten
      .select(&method(:exportable)).each_with_object({}) do |tech, object|
        object[tech.technology] = (object[tech.technology] || 0) + tech.units
      end
  end

  def exportable(technology)
    Technology.exists?(technology.type) &&
      Technology.by_key(technology.type).export_to.present?
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
    et_engine_gqueries['number_of_solar_pv']['future'] / number_of_households
  end

  # Private: Queries ETEngine to determine how many households exist in the
  # (scaled-down) scenario.
  #
  # Returns an Integer.
  def number_of_households
    et_engine_gqueries['households_number_of_residences']['future']
  end

  def et_engine_gqueries
    @et_engine_gqueries ||= EtEngineConnector.new(gqueries:
      %w(households_number_of_residences number_of_solar_pv)
    ).gquery(@testing_ground.scenario_id)
  end

  # Private: Limits the value of an input so that it may be submitted to
  # ETEngine without validation errors.
  #
  # Returns the value.
  def limit_value(value, input)
    [[value, ete_inputs[input]['max']].min, ete_inputs[input]['min']].max
  end

  # Private: The ETENgine input data, including the minimum and maximum
  # permitted values.
  #
  # Returns a Hash.
  def ete_inputs
    @ete_inputs ||= EtEngineConnector.new.inputs(@testing_ground.scenario_id)
  end
end
