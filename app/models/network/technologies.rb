module Network
  module Technologies
    # Public: Creates a new Technology instance, suited to represent the given
    # InstalledTechnology in the network calculation.
    #
    # Returns a Technology.
    def self.from_installed(installed, profile, options = {})
      behavior = installed.behavior_with_curve(options[:curve_type])
      behaviors[behavior].build(installed, profile, options)
    end

    # Public: A hash containing the permitted behaviors which may be used by
    # technologies in the testing ground.
    def self.behaviors
      @behaviors ||=
        Hash.new { Generic }.tap do |behaviors|
          behaviors['storage']            = Battery
          behaviors['congestion_battery'] = CongestionBattery
          behaviors['electric_vehicle']   = ElectricVehicle
          behaviors['optional_buffer']    = OptionalBuffer
          behaviors['siphon']             = Siphon
          behaviors['buffer']             = HeatPump
          behaviors['deferrable']         = DeferrableConsumer
          behaviors['conserving']         = ConservingProducer
          behaviors['optional']           = OptionalConsumer
          behaviors['hhp_electricity']    = HHP::Electricity
          behaviors['hhp_gas']            = HHP::Gas
          behaviors['null']               = Null
        end.freeze
    end
  end
end
