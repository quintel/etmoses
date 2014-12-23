class Import
  include ActiveModel::Validations

  URL_TEMPLATE = 'http://%s/api/v3/scenarios/%d/converters/stats'.freeze

  # A collection of converter keys representing technologies we need to fetch
  # from ETEngine.
  NODE_KEYS = YAML.load_file(Rails.root.join('db/import_technologies.yml'))

  attr_reader :provider, :scenario_id

  validates :provider,    inclusion: { in: Topology::IMPORT_PROVIDERS }
  validates :scenario_id, numericality: { only_integer: true }

  # Public: Creates a new Import with the given provider and scenario.
  #
  # Returns an Import.
  def initialize(attributes = {})
    @provider    = attributes[:provider] || Topology::IMPORT_PROVIDERS.first
    @scenario_id = attributes[:scenario_id]
  end

  # Public: Import data from the remote provider and return a Topology with
  # appropriate technologies.
  #
  # Returns a Topology.
  def topology
    Topology.new(technologies: technologies_from(response))
  end

  # Internal: Required in order to use Import within +form_for+ view block.
  def to_key
    nil
  end

  ######
  private
  ######

  # Internal: Imports the requested data from the remote provider and returns
  # the JSON response as a Hash.
  def response
    JSON.parse(RestClient.post(
      URL_TEMPLATE % [@provider, @scenario_id],
      { keys: NODE_KEYS }.to_json,
      { content_type: :json, accept: :json}
    ))['nodes']
  end

  # Internal: Given a response, splits out the nodes into discrete technologies.
  #
  # Returns a hash.
  def technologies_from(response)
    top = { "LV #1" => [], "LV #2" => [], "LV #3" => [] }

    response.each_with_object(top) do |(key, data), techs|
      data['number_of_units']['future'].floor.times do |index|
        techs["LV ##{ (index % 3) + 1 }"].push({
          'name' => "#{ key.titleize } ##{ index + 1 }"
        })
      end
    end
  end
end # Import
