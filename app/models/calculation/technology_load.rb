module Calculation
  class TechnologyLoad
    def self.call(context)
      new(context).run
    end

    def initialize(context)
      @context = context
    end

    def run
      resolution = 8760.0 / @context.length

      @context.graph.nodes.each do |node|
        node.set(:resolution, resolution)
      end

      @context.technology_nodes.each do |node|
        node.set(:techs, techs_for(node).flatten)
      end

      @context
    end

    private

    def techs_for(node)
      suitable_technologies(node).map do |tech|
        tech.each_profile_curve do |curve_type, curve, additional_curve|
          Network::Technologies.from_installed(
            tech, profile_for(tech, curve), @context.options.merge(
              curve_type: curve_type,
              additional_profile: additional_curve
            )
          )
        end
      end
    end

    # Internal: Given a node, returns an array of technologies which may be used
    # to determine the load on the node to which they belong.
    #
    # Returns an array of InstalledTechnology instances.
    def suitable_technologies(node)
      node.get(:installed_techs).select do |technology|
        technology.profile || technology.capacity ||
          technology.load || technology.volume
      end
    end

    # Internal: Given a technology, retrieves the load profile which may be used
    # to describe its load.
    #
    # Returns an Array or Network::Curve.
    def profile_for(technology, curve = nil)
      return curve if curve.present?

      # If the technology does not use a profile, but has a load or
      # capacity, we assume its load is constant throughout the year.
      self.class.constant_profile(technology, @context.length)
    end

    # Public: Given an installed technology and a length, creates a profile
    # which represents the load of the technology over time.
    #
    # An array with the given length will be returned.
    def self.constant_profile(technology, length)
      Network::Curve.new(
        [], length, (technology.electrical_capacity || 0.0) * technology.units)
    end
  end # TechnologyLoad
end # Calculation
