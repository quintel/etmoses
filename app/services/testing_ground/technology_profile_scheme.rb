class TestingGround
  class TechnologyProfileScheme
    #
    # Given a distributed set of technologies and a differentiation setting
    # Creates a Hash with the maximum amount of selected profiles or minimum
    # amount of selected profiles
    #

    def initialize(distribution)
      @distribution = distribution.map do |technology|
        InstalledTechnology.new(technology)
      end
    end

    # Returns a hash with all edge nodes as keys and technologies as values
    def build
      Hash[@distribution.group_by(&:node).map do |node, technologies|
        [node, technologies.map { |tech| tech.attributes.stringify_keys } ]
      end]
    end
  end
end
