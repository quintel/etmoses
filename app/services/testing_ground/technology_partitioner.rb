class TestingGround::TechnologyPartitioner
  include CompositeCoupler

  # Partitions technology in correct amount of pieces
  # For instance. When given a <InstalledTechnology type = x, units = 3>
  # and size = 3. It will duplicate this technology 3 times and reduce the
  # units down to 1.
  #

  def initialize(technology, size)
    @technology = technology
    @size       = size
    @counts     = associates_units
  end

  def partition
    duplicate_technologies
      .each_with_index.map(&method(:couple_composite))
      .reject(&method(:remove_zeros))
  end

  private

  def duplicate_technologies
    group_parts(@technology.units, @size).map do |units|
      clone_technology(@technology, units)
    end
  end

  def clone_technology(technology, units)
    technology       = technology.dup
    technology.units = units
    technology
  end

  def couple_composite(technology, index)
    if technology.composite? || technology.buffer.present?
      couple_composites(technology, index, @size)
    else
      technology
    end
  end

  def associates_units
    Hash[@technology.associates.map{|a| [a.type, a.units] }]
  end

  def group_parts(units, size)
    div, mod = units.divmod(size)

    Array.new(mod, div + 1) + Array.new(size - mod, div)
  end

  def remove_zeros(tech)
    tech.units.zero?
  end
end
