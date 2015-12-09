class TestingGround::TechnologyPartitioner
  def initialize(technology, size)
    @technology = technology
    @size       = size
    @counts     = associates_units
  end

  def partition
    duplicate_technologies.map
      .each_with_index(&method(:couple_composite))
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
    return technology unless technology.composite

    technology.composite_value = "buffer_#{ index + 1 }"

    technology.associates = technology.associates.map do |associate|
      associate        = associate.dup
      associate.buffer = technology.composite_value
      associate.units  = get_associate_units(associate.type, index)
      associate
    end

    technology
  end

  def get_associate_units(type, i)
    # Specify the remainder. It's either the amount of technologies which are
    # available per end node or the amount of technologies that you specified
    # in the first place
    # Depending on which produces the lowest number
    #
    # For example: 2 buffers, each buffer has 7 technologies
    # When looping this is the result:
    #
    # End-point 1
    #
    #   [7, 7] <- [technology count per node, amount of technologies for A]
    #   Assign 4 units of technology A to end-point 1
    #
    #   [3, 7] <- [technology count per node, amount of technologies for B]
    #   Assign 3 units of technology B to end-point 1
    #
    # End-point 2
    #
    #   [7, 3] <- ..
    #   [4, 4] <- ..
    #
    # Pick the highest number if the remaining technologies or node count is
    # is more than the highest number of groups
    # else pick the remaining number

    remainder  = units_per_node[i] <= @counts[type] ? units_per_node[i] : @counts[type]
    max_units  = max_units_for(type)
    units      = remainder < max_units ? remainder : max_units

    units_per_node[i] -= units
    @counts[type]     -= units

    units
  end

  def max_units_for(type)
    group_parts(associates_units[type], @size).max
  end

  def associates_units
    Hash[@technology.associates.map{|a| [a.type, a.units] }]
  end

  def units_per_node
    @units_per_node ||= group_parts(@technology.associates.sum(&:units), @size)
  end

  def group_parts(units, size)
    div, mod = units.divmod(size)

    Array.new(mod, div + 1) + Array.new(size - mod, div)
  end

  def remove_zeros(tech)
    tech.units.zero?
  end
end
