class TestingGround::TechnologyPartitioner
  module CompositeCoupler
    def couple_composites(technology, index, size = 1)
      @technology      = technology
      @size            = size
      @composite_index = composite_index(index)

      set_technology_attrs
    end

    private

    def set_technology_attrs
      @technology.composite_index = @composite_index

      if @technology.composite
        @technology.composite_value = composite_value
        @technology.associates      = associates
      end

      @technology
    end

    def associates
      @technology.associates.map do |associate|
        associate        = associate.dup
        associate.buffer = composite_value
        associate.units  = @technology.units
        associate
      end
    end

    def composite_index(index)
      ((@technology.composite_index || 0).to_i) * @size + index + 1
    end

    def composite_value
      "#{ @technology.type }_#{ @composite_index }"
    end
  end
end
