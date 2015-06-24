module Network
  # Represents a generic technology within the testing ground, which may have a
  # capacity and profile, or a constant load.
  class Technology
    # Public: Creates a new Technology instance, suited to represent the given
    # InstalledTechnology in the network calculation.
    #
    # Returns a Technology.
    def self.from_installed(installed, profile, options = {})
      behaviors[
        installed.behavior.presence || installed.technology.behavior
      ].build(installed, profile, options)
    end

    # Public: A hash containing the permitted behaviors which may be used by
    # technologies in the testing ground.
    def self.behaviors
      @behaviors ||=
        Hash.new { Technology }.tap do |behaviors|
          behaviors['storage']          = Battery
          behaviors['electric_vehicle'] = ElectricVehicle
          behaviors['buffer']           = Buffer
          behaviors['siphon']           = Siphon
          behaviors['preemptive']       = PreemptiveConsumer
          behaviors['deferrable']       = DeferrableConsumer
        end.freeze
    end

    def self.build(installed, profile, options)
      new(installed, profile)
    end

    attr_reader :installed, :profile

    def initialize(installed, profile)
      @installed = installed
      @profile   = profile
    end

    # TODO The name of this method suggests it checks to see if there is a
    # capacity restriction preventing fulfilment; that's not the case. Find a
    # better name.
    def capacity_constrained?
      false
    end

    def load_at(frame)
      @profile.at(frame)
    end

    def consumption
      @consumption ||= []
    end

    # Public: Determines the minimum amount of energy the technology consumes in
    # a given time-step.
    #
    # Mandatory consumption describes the amount of load which must be assigned
    # to the technology, regardless of excesses or deficits in the network.
    #
    # If the mandatory load of all consumers in the network exceeds
    # total production, the deficit will be supplied from the external grid.
    #
    # Returns a numeric.
    def mandatory_consumption_at(frame)
      consumer? ? load_at(frame) : 0.0
    end

    # Public: Determines the extra amount of energy the technology *may* consume
    # in addition to its mandatory load.
    #
    # Conditional load describes extra load which a technology may want if there
    # is an excess of production in the network. A common example might be the
    # remaining capacity in a battery, which should be fulfilled if there is
    # enough excess elsewhere.
    #
    # Returns a numeric.
    def conditional_consumption_at(frame)
      0.0
    end

    # Public: Determines the energy produced by the technology in the given
    # time-step.
    #
    # Returns a numeric.
    def production_at(frame)
      producer? ? load_at(frame).abs : 0.0
    end

    def capacity
      @installed.capacity || @installed.load || 0.0
    end

    def volume
      @installed.volume || Float::INFINITY
    end

    def consumer?
      capacity.present? && capacity >= 0 ||
        @installed.demand ||
        # When storage is disabled, it may turn into a normal technology in
        # order to draw load -- but NOT store -- from the network.
        @installed.volume
    end

    def producer?
      not consumer?
    end

    def storage?
      false
    end
  end
end
