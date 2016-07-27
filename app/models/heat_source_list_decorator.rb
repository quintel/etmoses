class HeatSourceListDecorator
  def initialize(heat_source_list)
    @heat_source_list = heat_source_list
  end

  def decorate
    sorted_asset_list.map do |part|
      entity = Technology.by_key(part.fetch(:key))

      InstalledHeatSource.new(part.merge(entity.attributes)) if entity
    end.compact
  end

  private

  def sorted_asset_list
    @heat_source_list.asset_list.sort_by do |source|
      source[:priority].to_i
    end
  end
end
