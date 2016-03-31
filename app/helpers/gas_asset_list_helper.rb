module GasAssetListHelper
  def options_for_gas_parts(part)
    options = DATA_SOURCES.keys.map do |key|
      [I18n.t("gas_asset.#{ key }"), key]
    end

    options_for_select(options, selected: part)
  end

  def options_for_pressure_levels(pressure_level)
    options_for_select([0.1, 4, 8, 40], pressure_level)
  end
end
