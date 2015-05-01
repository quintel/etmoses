module Calculation
  class TechnologyLoad
    def self.call(context)
      new(context).run
    end

    def initialize(context)
      @context = context
    end

    def run
      @context.technology_nodes.each do |node|
        node.set(:techs, suitable_technologies(node).map do |tech|
          Network::Technology.build(tech, profile_for(tech))
        end)
      end

      @context
    end

    #######
    private
    #######

    # Internal: Given a node, returns an array of technologies which may be used
    # to determine the load on the node to which they belong.
    #
    # Returns an array of InstalledTechnology instances.
    def suitable_technologies(node)
      node.get(:installed_techs).select do |technology|
        technology.profile || technology.capacity ||
          technology.load || technology.storage
      end
    end

    # Internal: Given a technology, retrieves the load profile which may be used
    # to describe its load.
    #
    # Returns an Array or Merit::Curve.
    def profile_for(technology)
      if technology.profile
        technology.profile_curve
      else
        # If the technology does not use a profile, but has a load or
        # capacity, we assume its load is constant throughout the year.
        Array.new(@context.length,
                  technology.load || technology.capacity || 0.0)
      end
    end
  end # TechnologyLoad
end # Calculation
