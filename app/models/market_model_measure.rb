class MarketModelMeasure
  def initialize(attributes = {}, topology_graph = {})
    @attributes = attributes
    @topology_graph = topology_graph
  end

  def measure
    OpenStruct.new({tariff: tariff})
  end

  private

  def tariff
    @attributes['tariff']
  end
end
