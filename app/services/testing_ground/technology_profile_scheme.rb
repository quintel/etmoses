class TestingGround
  class TechnologyProfileScheme
    #
    # Given a distributed set of technologies over end points and turns it
    # into a Hash grouped by node.
    #

    attr_accessor :distribution

    def initialize(distribution)
      @distribution = distribution.map do |technology|
        if technology.is_a?(InstalledTechnology)
          technology
        else
          InstalledTechnology.new(technology)
        end
      end
    end

    # Returns a hash with all edge nodes as keys and technologies as values
    def to_h
      Hash[@distribution.group_by(&:node).map do |node, technologies|
        [node, technologies.map { |tech| tech.attributes.stringify_keys } ]
      end]
    end
  end
end
