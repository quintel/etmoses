class TestingGround < ActiveRecord::Base
  serialize :technologies, TechnologyList

  belongs_to :topology
  accepts_nested_attributes_for :topology

  DEFAULT_TECHNOLOGIES = Rails.root.join('db/default_technologies.yml').read

  IMPORT_PROVIDERS = %w(beta.et-engine.com etengine.dev localhost:3000).freeze

  validates :topology, presence: true
  validate  :validate_technology_connections, if: :topology
  validate  :validate_technology_types

  before_validation do
    self.technologies = {} unless technologies
  end

  # Creates a hash representing the full topology to be rendered by D3. Copies
  # important attributes from the techologies hash into the topology.
  #
  # This should be moved to a presenter after the prototype stage.
  def as_json(opts = {})
    point = opts[:point] || 0

    calculators = [
      Calculation::TechnologyLoad,
      Calculation::Flows
    ]

    graph = calculators.reduce(to_graph) do |graph, calculator|
      calculator.call(graph, point)
    end

    { graph: GraphToTree.convert(graph), technologies: technologies_json(graph) }
  end

  # Public: Creates a Turbine graph representing the graph and technologies
  # defined in the topology.
  #
  # Returns a Turbine::Graph.
  def to_graph(point = 0)
    TreeToGraph.convert(topology.graph, technologies, point)
  end

  # Public: Given a calculated graph, returns the technologies JSON, injecting
  # the load of each technology into the appropriate hash.
  #
  # Returns a Hash.
  def technologies_json(graph)
    original = technologies.as_json

    original.each do |key, techs|
      (graph.node(key).get(:mo_techs) || []).each do |mo_tech|
        tech = techs.detect { |t| t[:name] == mo_tech.key.first }
        tech[:load] = mo_tech.load_curve.get(0)
      end
    end

    original
  end

  # Public: Sets the list of technologies associated with the TestingGround.
  def technologies=(techs)
    case techs
      when Hash   then super(TechnologyList.from_hash(techs))
      when String then super(TechnologyList.load(techs))
      else             super
    end
  end

  #######
  private
  #######

  # Asserts that the technologies used in the graph have all been defined in
  # the technologies collection.
  def validate_technology_connections
    node_keys = []
    topology.each_node { |node| node_keys.push(node[:name]) }

    technologies.keys.reject { |key| node_keys.include?(key) }.each do |key|
      errors.add(:technologies,
                 "includes a connection to missing node #{ key.inspect }")
    end
  end

  # Asserts that, whenever a user has defined that a technology uses a
  # pre-existing technology, that the technology actually exists.
  def validate_technology_types
    technologies.each_tech do |tech|
      if ! tech.exists?
        errors.add(
          :technologies, "has an unknown technology type: #{ tech.type }")
      elsif tech.profile
        unless tech.library.permitted_profile?(tech.profile)
          errors.add(
            :technologies,
            "may not use the #{ tech.profile.inspect } profile " \
            "with a #{ tech.type.inspect }")
        end

        if tech.profile && tech.load
          errors.add(
            :technologies,
            "may not have an explicitly set load, and also a load profile"
          )
        end
      end
    end
  end
end # TestingGround
