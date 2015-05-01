module Network
  # Implements an ElectricVehicle whose profile describes the minimum amount of
  # energy which must be stored in the technology in any given point.
  #
  # A negative value in the curve indicates that the vehicle is disconnected and
  # may not supply or consume any energy until reconnected. An ElectricVehicle
  # reconnects with zero energy stored.
  class ElectricVehicle < Storage
    def production_at(point)
      disconnected?(point) ? 0.0 : super
    end

    # Public: The minimum amount of energy required to fulfil the needs of the
    # vehicle in this time step.
    #
    # Returns a numeric.
    def mandatory_consumption_at(point)
      if disconnected?(point)
        0.0
      elsif profile
        profile.at(point)
      else
        super
      end
    end

    # Public: Describes the unfilled storage capacity which may be assigned from
    # excess production in the network.
    #
    # Returns a numeric.
    def conditional_consumption_at(point)
      disconnected?(point) ? 0.0 : super
    end

    #######
    private
    #######

    def disconnected?(point)
      profile && profile.at(point) < 0
    end
  end # ElectricVehicle
end # Network
