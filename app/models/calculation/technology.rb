module Calculation
  # Represents a generic technology within the testing ground, which may have a
  # capacity and profile, or a constant load.
  class Technology
    # Public: Creates a new Technology instance, suited to represent the given
    # InstalledTechnology in the network calculation.
    #
    # Returns a Technology.
    def self.build(installed, profile)
      if installed.storage
        Storage.new(installed, profile)
      else
        Technology.new(installed, profile)
      end
    end

    attr_reader :installed, :profile

    def initialize(installed, profile)
      @installed = installed
      @profile   = profile
    end

    def load_at(point)
      @profile.at(point)
    end

    # --

    alias_method :mandatory_consumption_at, :load_at

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
    def mandatory_consumption_at(point)
      consumer? ? load_at(point) : 0.0
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
    def conditional_consumption_at(point)
      0.0
    end

    # Public: Determines the energy produced by the technology in the given
    # time-step.
    #
    # Returns a numeric.
    def production_at(point)
      supplier? ? load_at(point).abs : 0.0
    end

    def capacity
      @installed.capacity || @installed.load
    end

    def consumer?
      capacity && capacity > 0
    end

    def supplier?
      not consumer?
    end

    def storage?
      false
    end
  end
end
