module Calculation
  # Given
  class TechnologyLoad
    def self.call(context)
      new(context).run
    end

    def initialize(context)
      @context = context
    end

    def run
      @context.technology_nodes.each do |node|
        profiles = profiles_for(suitable_technologies(node))

        @context.points do |point|
          node.set_load(point, profiles.map { |p| p.at(point) }.sum)
        end
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
      node.get(:techs).select do |technology|
        technology.profile || technology.capacity || technology.load
      end
    end

    # Internal: Given a collection of technologies which may be used to
    # determine end-point load, converts the load throughout the year to an
    # array (or Merit::Curve) which describes the load.
    #
    # Returns an Array or Merit::Curve.
    def profiles_for(technologies)
      technologies.map do |technology|
        if technology.profile
          technology.profile_curve
        else
          # If the technology does not use a profile, but has a load or
          # capacity, we assume its load is constant throughout the year.
          Array.new(@context.length, technology.load || technology.capacity || 0.0)
        end
      end
    end
  end # TechLoad
end # Calculation
