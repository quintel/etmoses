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
      @profile.at(point) * capacity
    end

    def capacity
      @installed.capacity || @installed.load
    end

    def producer?
      capacity && capacity > 0
    end

    def supplier?
      not producer?
    end

    def storage?
      false
    end
  end
end
