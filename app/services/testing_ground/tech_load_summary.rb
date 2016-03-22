# Given an endpoint from a calculated graph, returns a hash containing the
# load of each technology on the endpoint for each frame in the calculation.
class TestingGround::TechLoadSummary
  def self.summarize(network)
    Hash[network.nodes.select { |n| n.edges(:out).none? }.map do |endpoint|
      [endpoint.key, endpoint.get(:tech_loads) || new(endpoint).loads]
    end]
  end

  def initialize(node)
    @node = node
  end

  def loads
    if @node.get(:techs).present?
      grouped = @node.get(:techs).group_by { |tech| tech.installed.type }
      Hash[grouped.map { |type, techs| [type, loads_of(techs)] }]
    else
      {}
    end
  end

  private

  def loads_of(techs)
    @node.load.length.times.map do |frame|
      techs.reduce(0.0) { |sum, tech| sum + tech.load_at(frame) }
    end
  end
end
