class Import
  include ActiveModel::Validations

  attr_reader :provider, :scenario_id, :topology_id, :market_model_id

  validates :provider,    inclusion: { in: [Settings.etengine_host] }
  validates :scenario_id, numericality: { only_integer: true }
  validate :etm_scenario_present, if: -> { valid_scenario? }
  validate :scaled_scenario?, if: -> { valid_scenario? }

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
    etm_scenario[:title] || @scenario_id
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
    @technology_distribution ||= TestingGround::TechnologyDistributor.new(
      technologies, topology.graph).build
  end

  private

  def valid_scenario?
    scenario_id.present? && scenario_id =~ /^\d+$/
  end

  def scaled_scenario?
    return if etm_scenario[:scaling].present?

    errors.add(:scenario_id, 'is not scaled')
  end

  # Internal: Retrieves the ID of the national-scale preset or saved scenario.
  #
  # Returns a number, or nil if no national scenario was found.
  def parent_scenario_id
    etm_scenario[:template].try(:to_i)
  end

  # Internal: all technologies including houses
  #
  # Returns an array.
  def technologies
    Import::Technologies::Fetcher.new(etm_scenario).fetch
  end

  # Internal: Retrieves the scenario from ETModel
  #
  # Returns a JSON object or nil if the scenario doesn't exist on ETModel
  def etm_scenario
    @etm_scenario ||= EtEngineConnector.new
                      .scenario(@scenario_id)
                      .symbolize_keys
  end

  def etm_scenario_present
    return unless etm_scenario[:error]

    errors.add(:scenario, etm_scenario[:error])
  end
end # Import
