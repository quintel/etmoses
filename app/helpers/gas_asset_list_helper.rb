module GasAssetListHelper
  def options_for_gas_parts(part)
    options = DATA_SOURCES.keys.map do |key|
      [I18n.t("gas_asset.#{ key }"), key]
    end

    options_for_select(options, selected: part)
  end

  def options_for_pressure_levels(pressure_level)
    options = GasAssetList::PRESSURE_LEVELS.each_with_index.map do |item, index|
      [item, index]
    end

    options_for_select(options, selected: pressure_level)
  end
end
