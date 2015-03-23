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
    Rails.cache.fetch('import.import_targets') do
      Library::Technology.all.select(&:import?)
    end
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
      { keys: self.class.import_targets.map(&:key) }.to_json,
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
      units   = data['number_of_units']['future'].round
      target  = Library::Technology.find(key)
      imports = target.import_attributes
      title   = target.name || target.key.to_s.titleize

      base_attrs = imports.each_with_object({}) do |(local, remote), base|
        base[local] = extract_value(data, remote)
      end

      base_attrs['type'] = key

      units.times do |index|
        list.push(base_attrs.merge(
          'name' => "#{ title } ##{ index + 1 }"
        ))
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

  # Internal: Given a hash of values for a converter imported from ETEngine,
  # extracts the +name+d value.
  def extract_value(data, name)
    if name.start_with?('share_of ')
      actual = name[9..-1]
      value  = data.key?(actual) ? data[actual]['future'] : 0.0

      value / data['number_of_units']['future'].round
    else
      data.key?(name) ? data[name]['future'] : 0.0
    end
  end
end # Import
