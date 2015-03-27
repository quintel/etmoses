# Takes testing grounds and creates a full-size national scenario on ETEngine,
# based on the original scaled-down scenario and accounting for changes made in
# the testing ground.
class Export
  # Path to the scenarios section in ETEngine's API.
  API_BASE = 'http://beta.et-engine.com/api/v3/scenarios'.freeze

  # Public: Determines if the given testing ground has enough information to
  # permit exporting back to a national scenario.
  def self.can_export?(testing_ground)
    testing_ground.scenario_id.present?
  end

  def initialize(testing_ground)
    @testing_ground = testing_ground
  end

  # Public: Queries ETEngine to determine how many households exist in the
  # (scaled-down) scenario.
  #
  # Returns an Integer.
  def number_of_households
    @households ||= scenario_request(:put, gqueries: [
      'households_number_of_residences'
    ])['gqueries']['households_number_of_residences']['future']
  end

  # Public: Creates a hash containing the inputs and values to be sent to
  # ETEngine in order to reflect the state of the testing ground.
  #
  # Returns a Hash.
  def inputs
    Hash[technology_units.map do |tech_key, units|
      [ Library::Technology.find(tech_key).export_to,
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
    all_techs = @testing_ground.technologies.to_h.values.flatten
    count     = Hash.new { |hash, key| hash[key] = 0 }

    all_techs.each { |technology| count[technology.type] += 1 }

    count.reject do |key, _|
      (! Library::Technology.exists?(key)) ||
        Library::Technology.find(key).export_to.blank?
    end
  end

  # Public: Sends requests to ETEngine in order to create the national scenario.
  #
  # Returns the JSON response body as a Hash.
  def export
    # Exporting is a two-step procedure in which we create a new national-scale
    # scenario based on the original, then send the input values with a second
    # request.
    new_scenario = api_request(:post, nil, scenario: {
      scenario_id: @testing_ground.scenario_id, descale: true
    })

    api_request(:put, new_scenario['id'], {
      autobalance: true, force_balance: true,
      scenario: { title: @testing_ground.name, user_values: inputs }
    })

    new_scenario
  end

  #######
  private
  #######

  # Internal: Sends a request to the scenario URL on ETEngine to query
  # information about the original scenario.
  #
  # Returns the JSON response body as a hash.
  def scenario_request(method, params = {})
    api_request(method, @testing_ground.scenario_id.to_s, params)
  end

  # Internal: Sends a request to the ETEngine scenarios section.
  #
  # Returns the JSON response body as a hash.
  def api_request(method, suffix, params = {})
    url = [ API_BASE, suffix ].compact.join('/')

    JSON.parse(RestClient.public_send(
      method, url, params.merge(accept: :json)
    ))
  end
end
