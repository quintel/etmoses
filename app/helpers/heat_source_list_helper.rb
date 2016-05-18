module HeatSourceListHelper
  def heat_source_technologies
    Technology.for_carrier('heat') + [ Technology.generic ]
  end

  def options_for_heat_source_plant_types(key)
    heat_sources = heat_source_technologies.map do |heat_source|
      [ I18n.t("heat_sources.#{ heat_source.key }"),
        heat_source.key ]
    end

    options_for_select(heat_sources, selected: key)
  end
end
