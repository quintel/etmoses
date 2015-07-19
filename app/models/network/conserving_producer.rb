module Network
  # A production technology which should reduce its production in the event of
  # an excess of production in the network.
  class ConservingProducer < Technology
    extend Disableable

    # Creates a new ConservingProducer.
    #
    # installed - The InstalledTechnology which this represents.
    # profile   - The profile which describes
    def initialize(installed, profile, capping_fraction: 0.0, **)
      super
      @capping_fraction = capping_fraction
    end

    def self.disabled?(options)
      !options[:capping_solar_pv]
    end

    def self.disabled_class
      Technology
    end

    def conservable_production_at(frame)
      production = production_at(frame)

      capping = (capacity * ( 1.0 - @capping_fraction.to_f) ).abs

      production > capping ? production - capping : 0
    end

    def store(_frame, _amount)
    end
  end # ConservingProducer
end # Network
