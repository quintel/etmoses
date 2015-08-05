module Network
  module Technologies
    # Public: Creates a new Technology instance, suited to represent the given
    # InstalledTechnology in the network calculation.
    #
    # Returns a Technology.
    def self.from_installed(installed, profile, options = {})
      behavior = (installed.behavior.presence || installed.technology.behavior)

      if options[:curve_type] && options[:curve_type] != 'default'
        behavior = [behavior, options[:curve_type]].join("_")
      end

      behaviors[behavior].build(installed, profile, options)
    end

    # Public: A hash containing the permitted behaviors which may be used by
    # technologies in the testing ground.
    def self.behaviors
      @behaviors ||=
        Hash.new { Generic }.tap do |behaviors|
          behaviors['storage']          = Battery
          behaviors['electric_vehicle'] = ElectricVehicle
          behaviors['optional_buffer']  = OptionalBuffer
          behaviors['siphon']           = Siphon
          behaviors['buffer']           = Buffer
          behaviors['conserving']       = ConservingProducer
          behaviors['deferrable_flex']  = DeferrableConsumer
          behaviors['optional_flex']    = OptionalConsumer
        end.freeze
    end
  end
end
