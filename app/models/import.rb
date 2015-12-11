class Import
  include ActiveModel::Validations

  attr_reader :provider, :scenario_id, :topology_id, :market_model_id

  validates :provider,    inclusion: { in: [Settings.etengine_host] }
  validates :scenario_id, numericality: { only_integer: true }
  validate :etm_scenario_present, if: -> { scenario_id.present? }
  validate :is_scaled_scenario, if: -> { scenario_id.present? }

  # Public: Returns a hash of technologies which we can import from ETEngine.
  #
  # Each key is the name of a tehnology in ETEngine, and each value a hash
  # containing the technology attributes. Technologies whose attributes include
  # "import=false" will be omitted.
  #
  # Returns a hash.
  def self.import_targets
    Technology.joins(:importable_attributes)
      .group('importable_attributes.technology_id')
  end

  # Public: Creates a new Import with the given provider and scenario.
  #
  # Returns an Import.
  def initialize(attributes = {})
    @provider = Settings.etengine_host

    @scenario_id = attributes[:scenario_id]
    @topology_id = attributes[:topology_id]
    @market_model_id = attributes[:market_model_id]
  end

  # Public: Import data from the remote provider and return a TestingGround with
  # appropriate technologies.
  #
  # Returns a TestingGround.
  def testing_ground
    TestingGround.new(
      topology:                topology,
      technology_distribution: technology_distribution,
      technology_profile:      technology_profile,
      scenario_id:             @scenario_id,
      parent_scenario_id:      parent_scenario_id,
      market_model_id:         market_model_id)
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
    TestingGround::TechnologyProfileScheme.new(technology_distribution).build
  end

  def technology_distribution
    @technology_distribution ||= TestingGround::TechnologyDistributor.new(technologies, topology.graph).build
  end

  private

  def is_scaled_scenario
    unless etm_scenario["scaling"].present?
      self.errors.add(:scenario_id, "is not scaled")
    end
  end

  # Internal: Imports the requested data from the remote provider and returns
  # the JSON response as a Hash.
  def response
    @response ||= EtEngineConnector.new(
      { keys: self.class.import_targets.map(&:key) }
    ).stats(@scenario_id)['nodes']
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
    households + buildings + composites + default_technologies + hybrids
  end

  # Internal: non-hybrids
  #
  # Returns an array
  def default_technologies
    technologies_from - hybrids
  end

  # Internal: hybrid technologies
  #
  # Returns an array
  def hybrids
    HybridExpander.new(technologies_from.select do |technology|
      technology['carrier'] == "hybrid"
    end).expand
  end

  # Internal: Given a response, splits out the nodes into discrete technologies.
  #
  # Returns an array.
  def technologies_from
    @technologies_from ||= response.flat_map do |key, data|
      TechnologyBuilder.build(key, data)
    end
  end

  def buildings
    BuildingsBuilder.new(@scenario_id).build
  end

  # Internal: Given and etm scenario, creates a set of houses
  #
  # Returns an array.
  def households
    HouseBuilder.new(@scenario_id, etm_scenario["scaling"]).build
  end

  # Internal: Given and etm scenario, creates a set of composites
  #
  # Returns an array.
  def composites
    CompositeBuilder.new(@scenario_id, etm_scenario["scaling"]).build
  end

  # Internal: Retrieves the scenario from ETModel
  #
  # Returns a JSON object or nil if the scenario doesn't exist on ETModel
  def etm_scenario
    @etm_scenario ||= EtEngineConnector.new.scenario(@scenario_id)
  end

  def etm_scenario_present
    if etm_scenario[:error]
      errors.add(:scenario, etm_scenario[:error])
    end
  end
end # Import
