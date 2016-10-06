module HeatSourceListHelper
  def heat_source_technologies
    [ Technology.generic ] + Technology.heat_sources_for_table
  end

  def heat_source_technologies_for(dispatchable = true)
    heat_source_technologies.select { |tech| tech.dispatchable == dispatchable }
  end

  def create_options(technologies, key)
    heat_sources = technologies.map do |heat_source|
      [ I18n.t("heat_sources.#{ heat_source.key }"),
        heat_source.key, data: heat_source_defaults(heat_source) ]
    end

    options_for_select(heat_sources, selected: key)
  end

  def heat_source_defaults(heat_source)
    InstalledHeatSource.defaults.merge(heat_source.defaults)
  end

  def options_for_must_run_heat_source_plant_types(key = nil)
    create_options(heat_source_technologies_for(false), key)
  end

  def options_for_dispatchable_heat_source_plant_types(key = nil)
    create_options(heat_source_technologies_for, key)
  end

  def options_for_heat_source_plant_types(key)
    create_options(heat_source_technologies, key)
  end
end
