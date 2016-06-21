module HeatAssetListHelper
  def options_for_primary_heat_assets(type)
    options = HeatAssets::Pipe.all.map do |pipe|
      [pipe.type, pipe.type, data: pipe.attributes]
    end

    options_for_select(options, selected: type)
  end

  def options_for_secondary_heat_assets(type)
    options = HeatAssets::Location.all.map do |location|
      [location.type, location.type, data: location.attributes]
    end

    options_for_select(options, selected: type)
  end
end
