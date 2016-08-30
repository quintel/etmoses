class HeatSourceListDecorator
  def initialize(heat_source_list)
    @heat_source_list = heat_source_list
  end

  def decorate
    @heat_source_list.sorted_asset_list.map do |part|
      entity = Technology.find_by_key!(part.fetch(:key))

      InstalledHeatSource.new(part.merge(entity.attributes))
    end
  end
end
