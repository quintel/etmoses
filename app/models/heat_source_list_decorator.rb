class HeatSourceListDecorator
  def initialize(heat_source_list)
    @heat_source_list = heat_source_list
  end

  def decorate
    sorted_source_list.map do |part|
      entity = Technology.by_key(part.fetch('key'))

      InstalledHeatSource.new(part.merge(entity.attributes))
    end
  end

  private

  def sorted_source_list
    @heat_source_list.source_list.sort_by do |source|
      source['priority'].to_i
    end
  end
end
