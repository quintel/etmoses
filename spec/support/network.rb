module Moses
  module Spec
    module Network
      DEFAULT_OPTS = {
        strategies: {
          battery_storage: true,
          ev_capacity_constrained: true,
          ev_excess_constrained: true,
          ev_storage: true,
          solar_power_to_heat: true,
          capping_solar_pv: true,
          postponing_base_load: true,
          saving_base_load: true,
          hp_capacity_constrained: true,
          solar_power_to_gas: true
        }
      }.freeze

      # Public: Given an installed technology, creates a Network::Technology
      # which may represent it in Network specs.
      def network_technology(tech, profile_length = 8760, opts = {})
        opts[:additional_profile] &&=
          ::Network::Curve.from(opts[:additional_profile])

        if behavior = opts.delete(:behavior)
          allow(tech).to receive(:behavior).and_return(behavior)
        end

        if profile_length.is_a?(Array) || profile_length.is_a?(::Network::Curve)
          # If we were given a curve, use it without modification.
          profile = profile_length
        else
          # Otherwise we likely got an integer; create a static profile matching
          # the length.
          profile = network_curve(tech, profile_length)
        end

        ::Network::Technologies.from_installed(
          tech, profile, DEFAULT_OPTS.merge(opts))
      end

      # Internal: Creates a Network::Curve from the given values.
      def network_curve(tech, length)
        tech.profile && ::Network::Curve.new(tech.profile) ||
          Calculation::TechnologyLoad.constant_profile(tech, length)
      end
    end # Network
  end # Spec
end # Moses
