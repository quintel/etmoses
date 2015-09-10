module Network
  module Technologies
    # Provides class-level helpers for classes which are Disableable and use an
    # availability profile.
    module Availability
      # Internal:  With storage disabled, a car should consume energy from the
      # network as and when needed, without storing excesses for later use.
      def disabled_class
        Generic
      end

      # Internal: EV profiles describe the minimum amount of load to be stored
      # in each frame. Convert the profile to show the relative change over
      # time, which will give us the per-frame load of the vehicle.
      def disabled_profile(profile, _options)
        profile = profile.to_a
        to_kw   = profile.length.to_f / 8760.0
        first   = profile.at(0) < 0 ? 0.0 : profile.at(0)

        [first * to_kw, *(profile.each_cons(2).map do |previous, now|
          if now < 0
            0.0
          elsif previous < 0
            now * to_kw
          else
            (now - previous) * to_kw
          end
        end)]
      end
    end # Availability
  end
end
