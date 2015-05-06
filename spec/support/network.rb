module Ivy
  module Spec
    module Network
      # Public: Given an installed technology, creates a Network::Technology which
      # may represent it in Network specs.
      def network_technology(tech, profile_length = 2)
        ::Network::Technology.build(
          tech, tech.profile ||
            Calculation::TechnologyLoad.constant_profile(tech, profile_length)
        )
      end
    end # Network
  end # Spec
end # Ivy
