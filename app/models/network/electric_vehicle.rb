module Network
  # Implements an ElectricVehicle whose profile describes the minimum amount of
  # energy which must be stored in the technology in any given frame.
  #
  # A negative value in the curve indicates that the vehicle is disconnected and
  # may not supply or consume any energy until reconnected. An ElectricVehicle
  # reconnects with zero energy stored.
  class ElectricVehicle < Storage
    extend ProfileScaled

    # Electric vehicles are only capacity-constrained when load management is
    # turned on.
    attr_writer :capacity_constrained

    def self.build(installed, profile, options)
      instance = super

      unless disabled?(options)
        instance.capacity_constrained = options[:buffering_electric_car]
      end

      instance
    end

    def self.disabled?(options)
      options[:solar_storage]
    end

    # Internal:  With storage disabled, a car should consume energy from the
    # network as and when needed, without storing excesses for later use.
    def self.disabled_class
      Technology
    end

    # Internal: EV profiles describe the minimum amount of load to be stored in
    # each frame. Convert the profile to show the relative change over time,
    # which will give us the per-frame load of the vehicle.
    def self.disabled_profile(profile)
      profile = profile.to_a
      to_kw   = profile.length.to_f / 8760.0
      first   = profile[0] < 0 ? 0.0 : profile[0]

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

    def production_at(frame)
      disconnected?(frame) ? 0.0 : super
    end

    # Public: The minimum amount of energy required to fulfil the needs of the
    # vehicle in this time step.
    #
    # Returns a numeric.
    def mandatory_consumption_at(frame)
      if disconnected?(frame)
        0.0
      elsif profile
        @capacity.limit_mandatory(frame, profile.at(frame))
      else
        super
      end
    end

    # Public: Describes the unfilled storage capacity which may be assigned from
    # excess production in the network.
    #
    # Returns a numeric.
    def conditional_consumption_at(frame)
      disconnected?(frame) ? 0.0 : super
    end

    # Public: EVs should not overload the network.
    def capacity_constrained?
      @capacity_constrained
    end

    #######
    private
    #######

    def disconnected?(frame)
      profile && profile.at(frame) < 0
    end
  end # ElectricVehicle
end # Network
