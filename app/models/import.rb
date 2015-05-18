class Import
  include ActiveModel::Validations

  ETM_URLS = {
    stats:    'http://%s/api/v3/scenarios/%d/converters/stats',
    scenario: 'http://%s/api/v3/scenarios/%d'
  }.freeze

  attr_reader :provider, :scenario_id, :topology_id

  validates :provider,    inclusion: { in: TestingGround::IMPORT_PROVIDERS }
  validates :scenario_id, numericality: { only_integer: true }
  validate :is_scaled_scenario

  # Public: Returns a hash of technologies which we can import from ETEngine.
  #
  # Each key is the name of a tehnology in ETEngine, and each value a hash
  # containing the technology attributes. Technologies whose attributes include
  # "import=false" will be omitted.
  #
  # Returns a hash.
  def self.import_targets
    Technology.where('import_from IS NOT NULL')
  end

  # Public: Creates a new Import with the given provider and scenario.
  #
  # Returns an Import.
  def initialize(attributes = {})
    @provider =
      attributes[:provider] || TestingGround::IMPORT_PROVIDERS.first

    @scenario_id = attributes[:scenario_id]
    @topology_id = attributes[:topology_id]
  end

  # Public: Import data from the remote provider and return a TestingGround with
  # appropriate technologies.
  #
  # Returns a TestingGround.
  def testing_ground
    TestingGround.new(
      topology:           topology,
      technologies:       technologies,
      technology_profile: technology_profile,
      scenario_id:        @scenario_id,
      parent_scenario_id: parent_scenario_id)
  end

  def etm_title
    etm_scenario['title'] || @scenario_id
  end

  # Internal: Required in order to use Import within +form_for+ view block.
  def to_key
    nil
  end

  def topology
    if @topology_id.blank?
      Topology.default
    else
      Topology.find(@topology_id)
    end
  end

  def technology_profile
    TestingGround::TechnologyProfileScheme.new(
      technologies,
      topology.graph
    ).build
  end

  #######
  private
  #######

  def is_scaled_scenario
    unless etm_scenario["scaling"].present?
      self.errors.add(:scenario_id, "is not scaled")
    end
  end

  # Internal: Imports the requested data from the remote provider and returns
  # the JSON response as a Hash.
  def response
    @response ||= JSON.parse(RestClient.post(
      ETM_URLS[:stats] % [@provider, @scenario_id],
      { keys: self.class.import_targets.map(&:key) }.to_json,
      { content_type: :json, accept: :json }
    ))['nodes']
  end

  # Internal: Retrieves the ID of the national-scale preset or saved scenario.
  #
  # Returns a number, or nil if no national scenario was found.
  def parent_scenario_id
    etm_scenario['template'].try(:to_i)
  end

  # Internal: all technologies including houses
  #
  # Returns an array.
  def technologies
    technologies_from + households
  end

  # Internal: Given a response, splits out the nodes into discrete technologies.
  #
  # Returns an array.
  def technologies_from
    response.flat_map do |key, data|
      TechnologyBuilder.build(key, data)
    end
  end

  # Internal: Given and etm scenario, creates a set of houses
  #
  # Returns an array.
  def households
    HouseBuilder.new(@scenario_id, etm_scenario["scaling"]).build
  end

  # Internal: Retrieves the scenario from ETModel
  #
  # Returns a JSON object or nil if the scenario doesn't exist on ETModel
  def etm_scenario
    @etm_scenario ||= JSON.parse(RestClient.get(scenario_url))
  rescue RestClient::ResourceNotFound, JSON::ParserError
    nil
  end

  def scenario_url
    ETM_URLS[:scenario] % [@provider, @scenario_id]
  end
end # Import
