module HeatSourceListHelper
  def heat_source_technologies
    [ Technology.generic ] + Technology.heat_sources_for_table
  end

  def heat_source_technologies_for(type)
    heat_source_technologies.select do |tech|
      type == :all || (tech.dispatchable == (type == :dispatchable))
    end
  end

  def options_for_heat_source_plant_types(key, type = :all)
    heat_sources = heat_source_technologies_for(type).map do |heat_source|
      [ I18n.t("heat_sources.#{ heat_source.key }"),
        heat_source.key ]
    end

    options_for_select(heat_sources, selected: key)
  end
end
