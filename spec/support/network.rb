module Ivy
  module Spec
    module Network
      # Public: Given an installed technology, creates a Network::Technology which
      # may represent it in Network specs.
      def network_technology(tech, profile_length = 8760, opts = {})
        profile = tech.profile ||
          Calculation::TechnologyLoad.constant_profile(tech, profile_length)

        ::Network::Technology.from_installed(tech, profile, opts)
      end
    end # Network
  end # Spec
end # Ivy
