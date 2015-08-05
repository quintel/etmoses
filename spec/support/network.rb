module Moses
  module Spec
    module Network
      DEFAULT_OPTS = {
        battery_storage: true,
        solar_storage: true,
        solar_power_to_heat: true,
        capping_solar_pv: true,
        postponing_base_load: true,
        buffering_electric_car: true,
        saving_base_load: true,
        buffering_heat_pumps: true,
        solar_power_to_gas: true
      }.freeze

      # Public: Given an installed technology, creates a Network::Technology which
      # may represent it in Network specs.
      def network_technology(tech, profile_length = 8760, opts = {})
        ::Network::Technologies.from_installed(
          tech, network_curve(tech, profile_length), DEFAULT_OPTS.merge(opts))
      end

      # Internal: Creates a Network::Curve from the given values.
      def network_curve(tech, length)
        tech.profile && ::Network::Curve.new(tech.profile) ||
          Calculation::TechnologyLoad.constant_profile(tech, length)
      end
    end # Network
  end # Spec
end # Moses
