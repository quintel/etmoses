class Import
  include ActiveModel::Validations

  URL_TEMPLATE = 'http://%s/api/v3/scenarios/%d/converters/stats'.freeze

  # A collection of converter keys representing technologies we need to fetch
  # from ETEngine.
  NODE_KEYS = YAML.load_file(Rails.root.join('db/import_technologies.yml'))

  attr_reader :provider, :scenario_id, :topology_id

  validates :provider,    inclusion: { in: TestingGround::IMPORT_PROVIDERS }
  validates :scenario_id, numericality: { only_integer: true }

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
      topology:     topology,
      technologies: technologies_from(response))
  end

  # Internal: Required in order to use Import within +form_for+ view block.
  def to_key
    nil
  end

  def topology
    if @topology_id.blank?
      Topology.new(graph: YAML.load(Topology::DEFAULT_GRAPH))
    else
      Topology.new(graph: Topology.find(@topology_id).graph)
    end
  end

  #######
  private
  #######

  # Internal: Imports the requested data from the remote provider and returns
  # the JSON response as a Hash.
  def response
    JSON.parse(RestClient.post(
      URL_TEMPLATE % [@provider, @scenario_id],
      { keys: NODE_KEYS }.to_json,
      { content_type: :json, accept: :json }
    ))['nodes']
  end

  # Internal: Given a response, splits out the nodes into discrete technologies.
  #
  # Returns a hash.
  def technologies_from(response)
    # Figure out which nodes are the "leaf" nodes.

    graph = TreeToGraph.convert(topology.graph)

    topo = graph.nodes.select { |n| n.edges(:out).empty? }.map do |node|
      { key: node.key, techs: [] }
    end

    # Combine the technologies into an array so that they can be distributed
    # evenly.

    techs = response.each_with_object([]) do |(key, data), list|
      data['number_of_units']['future'].round.times do |index|
        list.push('name' => "#{ key.titleize } ##{ index + 1 }")
      end
    end

    techs.each_with_index do |tech, index|
      topo[index % topo.length][:techs].push(tech)
    end

    # Convert the array of nodes back into one big technology hash.

    topo.each_with_object({}) do |tech, hash|
      hash[tech[:key]] = tech[:techs]
    end
  end
end # Import
