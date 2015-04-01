class Import
  include ActiveModel::Validations

  URL_TEMPLATE = 'http://%s/api/v3/scenarios/%d/converters/stats'.freeze

  attr_reader :provider, :scenario_id, :topology_id

  validates :provider,    inclusion: { in: TestingGround::IMPORT_PROVIDERS }
  validates :scenario_id, numericality: { only_integer: true }

  # Internal: A hash of attributes which may be imported from ETEngine.
  ATTRIBUTES = Hash[[ DemandAttribute,
                      ElectricityOutputCapacityAttribute,
                      InputCapacityAttribute ].map do |attribute|
    [attribute.remote_name, attribute]
  end].with_indifferent_access.freeze

  # Public: Retrieves the Attribute responsible for importing the given ETEngine
  # attribute key.
  def self.attribute(key)
    ATTRIBUTES[key]
  end

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
      topology:     topology,
      technologies: technologies_from(response),
      scenario_id:  @scenario_id)
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

    available_profiles = permitted_profiles(response.keys)

    techs = response.each_with_object([]) do |(key, data), list|
      units     = data['number_of_units']['future'].round
      target    = Technology.by_key(key)
      title     = target.name || target.key.to_s.titleize
      attribute = self.class.attribute(target.import_from)

      # Attributes common to all installed versions of this technology.
      attrs = { 'type' => key, attribute.local_name => attribute.call(data) }

      # Filter the profiles leaving only those suitable for the technology.
      profiles = (available_profiles[key] || []).dup

      # Add each individual "unit" of the technology to the testing ground.
      units.times do |index|
        tech_data = attrs.merge('name' => "#{ title } ##{ index + 1 }")

        if profiles.any?
          tech_data['profile'] = select_profile(profiles)
        end

        list.push(tech_data)
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

  # Public: Given a list of technologies which appear in the testing ground,
  # returns a hash of technology keys and the load profiles which may be
  # assigned to them.
  #
  # Returns a hash.
  def permitted_profiles(technologies)
    permits = PermittedTechnology
      .where(technology: technologies)
      .includes(:load_profile)

    Hash[permits.group_by(&:technology).map do |tech_key, techs|
      [tech_key, techs.map(&:load_profile)]
    end]
  end

  # Public: Given a list of available profiles, returns a load profile key for
  # the technology.
  #
  # Returns the profile key as a String.
  def select_profile(profiles)
    # Move the profile to the bottom of the stack so that the *next* profile
    # assignment doesn't use it (this is round-robin selection).
    profile = profiles.shift
    profiles.push(profile)

    profile.key
  end
end # Import
