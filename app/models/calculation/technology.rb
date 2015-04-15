module Calculation
  # Represents a generic technology within the testing ground, which may have a
  # capacity and profile, or a constant load.
  class Technology
    # Public: Creates a new Technology instance, suited to represent the given
    # InstalledTechnology in the network calculation.
    #
    # Returns a Technology.
    def self.build(installed, profile, units = 1.0)
      if installed.storage
        Storage.new(installed, profile, units)
      else
        Technology.new(installed, profile, units)
      end
    end

    attr_reader :installed, :profile, :units

    def initialize(installed, profile, units = 1.0)
      @installed = installed
      @profile   = profile
      @units     = units
    end

    def load_at(point)
      @profile.at(point) * @units
    end

    def capacity
      (@installed.capacity || @installed.load) * @units
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
