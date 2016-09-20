class TechnologyProfileCalculationDecorator
  def initialize(technology_profile)
    @technology_profile = technology_profile
  end

  def decorate
    TechnologyList.new(profile)
  end

  private

  def profile
    Hash[@technology_profile.list.each_pair.map do |node, technologies|
      [ node, technologies.flat_map(&method(:decorate_technology)) ]
    end]
  end

  def decorate_technology(technology)
    if technology.components && technology.components.size > 0
      technology.components.map do |component|
        component.buffer = technology.buffer
        component.units  = technology.units
        component
      end
    else
      technology
    end
  end
end
