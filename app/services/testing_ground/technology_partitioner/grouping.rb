class TestingGround::TechnologyPartitioner
  module Grouping
    def group_parts(units, size)
      div, mod = units.divmod(size)

      Array.new(mod, div + 1) + Array.new(size - mod, div)
    end
  end
end
