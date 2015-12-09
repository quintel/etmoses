class TestingGround
  class TechnologyConnector
    def initialize(distribution)
      @distribution = distribution
    end

    def connect
      (associate_composites + non_composites).flatten
    end

    private

    def associate_composites
      composites.map do |composite|
        composite.associates = (@distribution - [composite]).select do |technology|
          technology.buffer == composite.composite_value
        end
        composite
      end
    end

    def non_composites
      (@distribution - composites - composites_children).map do |technology|
        [technology, []]
      end
    end

    def composites
      @distribution.select(&:composite)
    end

    def composites_children
      @distribution.select do |technology|
        !technology.composite && technology.buffer.present?
      end
    end
  end
end
