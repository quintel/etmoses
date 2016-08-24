class TestingGround < ActiveRecord::Base
  class DataError < StandardError; end;

  include Privacy

  DEFAULT_TECHNOLOGIES = Rails.root.join('db/default_technologies.yml').read
  CACHE_CLEARING_ATTRS = %w(technology_profile topology_id)

  serialize :technology_profile, TechnologyList

  belongs_to :topology
  belongs_to :market_model
  belongs_to :user
  belongs_to :behavior_profile

  # All has_one relations are duplicated when a visitor creates a clone of an
  # LES using TestingGround::SaveAs.
  has_one :selected_strategy, dependent: :destroy
  has_one :business_case,     dependent: :destroy
  has_one :gas_asset_list,    dependent: :destroy
  has_one :heat_source_list,  dependent: :destroy
  has_one :heat_asset_list,   dependent: :destroy

  has_many :testing_ground_delayed_jobs

  validates :topology, presence: true
  validates :name, presence: true, length: { maximum: 100 }

  validate  :validate_technology_profile_connections, if: :topology
  validate  :validate_technology_profile_types
  validate  :validate_technology_profile_units
  validate  :validate_inline_technology_profiles
  validate  :validate_load_profiles

  after_save :set_cache_updated_at

  def self.latest_first
    order(created_at: :desc)
  end

  # Creates a hash representing the full topology to be rendered by D3. Copies
  # important attributes from the techologies hash into the topology.
  #
  # This should be moved to a presenter after the prototype stage.
  def as_json(opts = {})
    { graph: GraphToTree.convert(to_calculated_graph(opts)),
      technologies: technology_profile.as_json }
  end

  # Public: Converts the testing ground to a Network::Graph and calculated the
  # loads for the entire year.
  #
  # This is a temporary method for backward compatibility. It will be removed
  # soon.
  #
  # Returns the Network::Graph.
  def to_calculated_graph(opts = {})
    to_calculated_graphs(opts).detect { |g| g.carrier == :electricity }
  end

  # Public: Converts the testing ground into separate Network::Graph instances
  # for each carrier, and loads are calculated for the entire year.
  #
  # Returns an array of Network::Graphs.
  def to_calculated_graphs(opts = {})
    calculators = [
      Calculation::TechnologyLoad,
      Calculation::PullConsumption,
      Calculation::Flows
    ]

    opts[:strategies] ||= {}

    context = calculators
      .reduce(to_calculation_context(opts.symbolize_keys)) do |cxt, calculator|
        calculator.call(cxt)
      end

    context.graphs
  end

  # Public: Creates a Calculation::Context which contains all the information
  # needed to calculate the testing ground.
  #
  # Returns a Calculation::Context.
  def to_calculation_context(options = {})
    Calculation::Context.new(
      [network(:electricity), network(:gas), network(:heat)], options.merge(
        behavior_profile: behavior_profile.try(:network_curve)
      )
    )
  end

  # Public: Creates a Network::Graph representing the topology and technologies
  # defined.
  #
  # carrier - A symbol naming which carrier's network is to be built.
  #
  # Returns a Network::Graph.
  def network(carrier)
    Network::Builders.for(carrier).build(
      topology.graph,
      TechnologyProfileCalculationDecorator.new(technology_profile).decorate,
      heat_source_list
    )
  end

  # Public: Given a calculated graph, returns the technologies JSON, injecting
  # the load of each technology into the appropriate hash.
  #
  # Returns a Hash.
  def technologies_json(graph)
    original = technology_profile.as_json

    original.each do |key, techs|
      (graph.node(key).get(:mo_techs) || []).each do |mo_tech|
        tech = techs.detect { |t| t[:name] == mo_tech.key.first }
        tech[:load] = mo_tech.load_curve.get(0)
      end
    end

    original
  end

  # Public: Sets the list of technologies associated with the TestingGround.
  def technology_profile=(techs)
    case techs
      when Hash   then super(TechnologyList.from_hash(techs))
      when String then super(TechnologyList.load(techs))
      else             super
    end
  end

  # Public: Set the technologies using an imported CSV file.
  def technology_profile_csv=(csv)
    csv = csv.read if csv.respond_to?(:read)
    self.technology_profile = TechnologyList.from_csv(csv)
  end

  def range
    range_start..range_end
  end

  def range=(range)
    return unless range.is_a?(Range)

    self.range_start = range.begin
    self.range_end   = range.end
  end

  private

  # Asserts that the technologies used in the graph have all been defined in
  # the technologies collection.
  def validate_technology_profile_connections
    node_keys = []
    topology.each_node { |node| node_keys.push(node[:name]) }

    technology_profile.keys.reject { |key| node_keys.include?(key) }.each do |key|
      errors.add(:technology_profile,
                 "includes a connection to missing node #{ key.inspect }")
    end
  end

  def validate_load_profiles
    technology_profile.each_tech do |tech|
      next if tech.profile_key.nil?

      if ! LoadProfile.find_by_key(tech.profile_key).present?
        errors.add(
          :technology_profile, "has an unknown load profile: #{ tech.profile_key }")
      end
    end
  end

  # Asserts that, whenever a user has defined that a technology uses a
  # pre-existing technology, that the technology actually exists.
  def validate_technology_profile_types
    technology_profile.each_tech do |tech|
      if ! tech.exists?
        errors.add(
          :technology_profile, "has an unknown technology type: #{ tech.type }")
      end
    end
  end

  # Asserts that technology "units" is either undefined, or greater than zero.
  def validate_technology_profile_units
    technology_profile.each_tech do |tech|
      if tech.units && tech.units < 0
        errors.add(:technology_profile, "may not have fewer than zero units")
      end
    end
  end

  def validate_inline_technology_profiles
    technology_profile.each_tech do |tech|
      next unless tech.profile.is_a?(Array)
      next unless tech.profile.any? { |value| ! value.is_a?(Numeric) }

      errors.add(
        :technology_profile,
        "may not have an inline curve with non-numeric values " \
        "(on #{ tech.name })"
      )
    end
  end

  def set_cache_updated_at
    touch(:cache_updated_at) if clear_cache?
  end

  def clear_cache?
    CACHE_CLEARING_ATTRS.any? do |attr|
      public_send("#{ attr }_changed?")
    end
  end
end # TestingGround
