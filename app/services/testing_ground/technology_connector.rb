class TestingGround
  class TechnologyConnector
    def self.connect(distribution)
      new(distribution).connect
    end

    def initialize(distribution)
      @distribution = distribution
        .group_by(&:concurrency_group)
        .values.flatten
    end

    def connect
      associates + non_associates
    end

    private

    def associates
      @distribution.select(&:composite).map do |composite|
        composite.associates = attach_technology(composite)
        composite
      end
    end

    def non_associates
      @distribution.reject do |tech|
        tech.composite? || tech.position_relative_to_buffer.present?
      end
    end

    # Since this class is used twice (once for the initial import and another
    # time for the concurrency). There are two ways of connecting a technology
    # to a buffer.
    #
    # If the composite value is set for a buffer and a technology
    # that sticks to it has a buffer value. They should look for those if not
    # use the initial includes to determine a possible match.
    #
    def attach_technology(technology)
      @distribution.select do |tech|
        if technology.composite_value.present?
          technology.composite_value == tech.buffer
        else
          technology.includes.include?(tech.type)
        end
      end
    end
  end
end
