module Network
  # Implements an ElectricVehicle whose profile describes the minimum amount of
  # energy which must be stored in the technology in any given frame.
  #
  # A negative value in the curve indicates that the vehicle is disconnected and
  # may not supply or consume any energy until reconnected. An ElectricVehicle
  # reconnects with zero energy stored.
  class ElectricVehicle < Storage
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
        profile.at(frame)
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

    #######
    private
    #######

    def disconnected?(frame)
      profile && profile.at(frame) < 0
    end
  end # ElectricVehicle
end # Network
