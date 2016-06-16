module OptionsHelper
  def options_for_composites(profile, composite)
    composites = profile.each_tech.select(&:composite).select do |technology|
      technology.type == composite.key
    end

    options_for_select(composites.map do |composite|
      [ composite.name + composite.name_adjective,
        composite.composite_value,
        { data: { includes: composite.includes } } ]
    end)
  end
end
