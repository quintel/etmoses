class TestingGround < ActiveRecord::Base
  serialize :technologies, JSON

  belongs_to :topology
  accepts_nested_attributes_for :topology

  DEFAULT_TECHNOLOGIES = Rails.root.join('db/default_technologies.yml').read

  IMPORT_PROVIDERS = %w(beta.et-engine.com etengine.dev localhost:3000).freeze

  validates :topology, presence: true
  validate  :validate_technology_connections, if: :topology

  before_validation do
    self.technologies = {} unless technologies
  end

  # Creates a hash representing the full topology to be rendered by D3. Copies
  # important attributes from the techologies hash into the topology.
  #
  # This should be moved to a presenter after the prototype stage.
  def as_json(*)
    graph = GraphToTree.convert(Calculator.calculate(to_graph))
    { graph: graph, technologies: technologies }
  end

  # Public: Creates a Turbine graph representing the graph and technologies
  # defined in the topology.
  #
  # Returns a Turbine::Graph.
  def to_graph
    TreeToGraph.convert(topology.graph, technologies)
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
end
