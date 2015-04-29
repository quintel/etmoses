class Import
  include ActiveModel::Validations

  URL_TEMPLATE = 'http://%s/api/v3/scenarios/%d/converters/stats'.freeze

  attr_reader :provider, :scenario_id, :topology_id

  validates :provider,    inclusion: { in: TestingGround::IMPORT_PROVIDERS }
  validates :scenario_id, numericality: { only_integer: true }

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
      technologies:       technologies_from(response),
      scenario_id:        @scenario_id,
      parent_scenario_id: parent_scenario_id)
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
      { keys: self.class.import_targets.map(&:key) }.to_json,
      { content_type: :json, accept: :json }
    ))['nodes']
  end

  # Internal: Retrieves the ID of the national-scale preset or saved scenario.
  #
  # Returns a number, or nil if no national scenario was found.
  def parent_scenario_id
    JSON.parse(RestClient.get(scenario_url))['template'].try(:to_i)
  rescue RestClient::ResourceNotFound, JSON::ParserError
    nil
  end

  # Internal: Given a response, splits out the nodes into discrete technologies.
  #
  # Returns a hash.
  def technologies_from(response)
    techs = technology_units_from(response)
    graph = TreeToGraph.convert(topology.graph)

    # Create an array containing the leaf nodes so that we may assign
    # technologies.
    topo = graph.nodes.select { |n| n.edges(:out).empty? }.map do |node|
      { key: node.key, techs: [] }
    end

    techs.each_with_index do |tech, index|
      topo[index % topo.length][:techs].push(tech)
    end

    # Convert the array of nodes back into one big technology hash.
    topo.each_with_object({}) do |tech, hash|
      hash[tech[:key]] = tech[:techs]
    end
  end

  # Internal: Given the ETEngine response, returns an array containing all
  # techologies which will exist in the testing ground.
  #
  # Returns an array.
  def technology_units_from(response)
    available_profiles = ProfileSelector.new(response.keys)

    response.flat_map do |(key, data)|
      TechnologyBuilder.build(key, data, available_profiles.for_tech(key))
    end
  end

  def scenario_url
    [Export::API_BASE, scenario_id].join("/")
  end
end # Import
