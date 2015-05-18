# Takes testing grounds and creates a full-size national scenario on ETEngine,
# based on the original scaled-down scenario and accounting for changes made in
# the testing ground.
class Export
  def initialize(testing_ground)
    @testing_ground = testing_ground
  end

  # Public: Queries ETEngine to determine how many households exist in the
  # (scaled-down) scenario.
  #
  # Returns an Integer.
  def number_of_households
    @households ||= EtEngineConnector.new(gqueries: [
      'households_number_of_residences'
    ]).gquery['gqueries']['households_number_of_residences']['future']
  end

  # Public: Creates a hash containing the inputs and values to be sent to
  # ETEngine in order to reflect the state of the testing ground.
  #
  # Returns a Hash.
  def inputs
    Hash[technology_units.map do |tech_key, units|
      [ Technology.by_key(tech_key).export_to,
        (units / number_of_households) * 100 ]
    end]
  end

  # Public: Creates a hash desribing each technology and the number of units of
  # said technology in the testing ground.
  #
  # Each key is the key of a technology, and each value the number of units.
  #
  # Returns a Hash.
  def technology_units
    all_techs = @testing_ground.technology_profile.to_h.values.flatten
    count     = Hash.new { |hash, key| hash[key] = 0 }

    all_techs.each { |technology| count[technology.type] += 1 }

    count.reject do |key, _|
      (! Technology.exists?(key: key)) ||
        Technology.by_key(key).export_to.blank?
    end
  end

  # Public: Sends requests to ETEngine in order to create the national scenario.
  #
  # Returns the JSON response body as a Hash.
  def export
    # Exporting is a two-step procedure in which we create a new national-scale
    # scenario based on the original, then send the input values with a second
    # request.
    new_scenario = EtEngineConnector.new(scenario_params).create_scenario

    EtEngineConnector.new(update_scenario_params)
      .update_scenario(new_scenario['id'])

    new_scenario
  end

  #######
  private
  #######

    def scenario_params
      { scenario: {
          scenario_id: @testing_ground.scenario_id,
          descale: true
        }
      }
    end

    def update_scenario_params
      { autobalance: true,
        force_balance: true,
        scenario: {
          title: @testing_ground.name,
          user_values: inputs
        }
      }
    end
end
