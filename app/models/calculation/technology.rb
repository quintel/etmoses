module Calculation
  class Technology
    attr_reader :installed, :profile

    def initialize(installed, profile)
      @installed = installed
      @profile   = profile
    end

    def flow_at(point)
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
