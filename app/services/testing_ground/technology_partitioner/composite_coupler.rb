class TestingGround::TechnologyPartitioner
  module CompositeCoupler
    def couple_composites(technology, index)
      @technology = technology
      @index      = index

      set_technology_attrs
    end

    private

    def set_technology_attrs
      @technology.composite_index = composite_index

      if @technology.composite
        @technology.composite_value = @technology.get_composite_value
        @technology.associates      = associates
      end

      @technology
    end

    def associates
      @technology.associates.map do |associate|
        associate        = associate.dup
        associate.buffer = @technology.composite_value
        associate.units  = get_associate_units(associate.type, @index)
        associate
      end
    end

    def composite_index
      ((@technology.composite_index || 0).to_i) * @size + @index + 1
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
      @counts[type] -= units

      units
    end

    def max_units_for(type)
      group_parts(associates_units[type], @size).max
    end

    def units_per_node
      @units_per_node ||= group_parts(@technology.associates.sum(&:units), @size)
    end
  end
end
