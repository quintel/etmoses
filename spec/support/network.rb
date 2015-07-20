module Moses
  module Spec
    module Network
      DEFAULT_OPTS = {
        battery_storage: true,
        solar_storage: true,
        solar_power_to_heat: true,
        capping_solar_pv: true,
        postponing_base_load: true,
        buffering_electric_car: false,
        saving_base_load: true,
        buffering_heat_pumps: true,
        solar_power_to_gas: true
      }.freeze

      # Public: Given an installed technology, creates a Network::Technology which
      # may represent it in Network specs.
      def network_technology(tech, profile_length = 8760, opts = {})
        opts = DEFAULT_OPTS.merge(opts)

        profile = tech.profile ||
          Calculation::TechnologyLoad.constant_profile(tech, profile_length)

        ::Network::Technologies.from_installed(tech, profile, opts)
      end
    end # Network
  end # Spec
end # Moses
