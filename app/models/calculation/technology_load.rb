module Calculation
  class TechnologyLoad
    HOURS_IN_YEAR = 8760.0

    def self.call(context)
      new(context).run
    end

    def initialize(context)
      @context = context
    end

    def run
      resolution = HOURS_IN_YEAR / @context.length

      @context.graphs.each do |graph|
        graph.nodes.each { |node| node.set(:resolution, resolution) }
      end

      @context.technology_nodes.each do |node|
        node.set(:comps, comps_for(node))
        node.set(:techs, techs_for(node))
      end

      @context
    end

    private

    def techs_for(node)
      suitable_technologies(node).flat_map do |tech|
        tech.profile_curve(@context.options[:range]).each do |curve_type, curve, additional_curve|
          if tech.buffer.present?
            # Returns the technology wrapped in a Composite::Wrapper.
            # composite(node, tech.buffer).add(net_tech)
            create_tech_for_composite(
              composite(node, tech.buffer),
              tech, curve_type, curve, additional_curve
            )
          else
            create_tech(tech, curve_type, curve, additional_curve)
          end
        end
      end
    end

    def create_tech_for_composite(composite, tech, curve_type, curve, additional_curve)
      # Storage technologies belonging to a composite must have the same volume
      # as the composite.
      tech.volume = composite.volume

      composite.add(create_tech(tech, curve_type, curve, additional_curve))
    end

    def create_tech(tech, curve_type, curve, additional_curve)
      Network::Technologies.from_installed(
        tech, profile_for(tech, curve),
        @context.options.merge(
          curve_type: curve_type,
          additional_profile: additional_curve
        )
      )
    end

    def comps_for(node)
      node.get(:installed_comps).each_with_object({}) do |comp, hash|
        hash[comp.composite_value] =
          Network::Technologies::Composite::Manager.new(
            (comp.capacity || Float::INFINITY) * comp.units,
            comp.volume * comp.units,
            comp.profile_curve(@context.options[:range]).cut_curves.fetch('default'.freeze)
          )
      end
    end

    def composite(node, name)
      @context.graph(:electricity).node(node.key).get(:comps).fetch(name)
    end

    # Internal: Given a node, returns an array of technologies which may be used
    # to determine the load on the node to which they belong.
    #
    # Returns an array of InstalledTechnology instances.
    def suitable_technologies(node)
      node.get(:installed_techs).select do |technology|
        technology.profile || technology.capacity || technology.volume
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
        [], length, (technology.carrier_capacity || 0.0) * technology.units)
    end
  end # TechnologyLoad
end # Calculation
