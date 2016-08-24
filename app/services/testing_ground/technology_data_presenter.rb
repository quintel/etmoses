class TestingGround::TechnologyDataPresenter
  def initialize(technology, node)
    @technology = technology
    @node = node
  end

  def present
    stringify_values(
      @technology.attributes
        .slice(*InstalledTechnology::EDITABLES)
        .merge(technology_attributes)
        .merge(component_attributes)
    )
  end

  private

  def stringify_values(hash)
    Hash[hash.map { |k, v| [k, v.to_s] }]
  end

  def technology_attributes
    {
      node: @node,
      includes: @technology.includes,
      sticks_to_composite: @technology.sticks_to_composite?,
      components: @technology.technology.components
    }
  end

  def component_attributes
    @technology.components.inject({}) do |object, component|
      object.merge(attributes_for_component(component))
    end
  end

  def attributes_for_component(component)
    editables = InstalledTechnology::COMPONENT_EDITABLES

    Hash[component.attributes.slice(*editables).map do |key, value|
      ["#{ component.type }_#{ key }", value]
    end]
  end
end
