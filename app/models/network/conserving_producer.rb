module Network
  # A production technology which should reduce its production in the event of
  # an excess of production in the network.
  class ConservingProducer < Technology
    extend Disableable

    def initialize(installed, profile, options)
      super
      @capping_fraction = options.fetch(:capping_fraction)
    end

    def self.disabled?(options)
      !options[:capping_solar_pv]
    end

    def self.disabled_class
      Technology
    end

    def production_at(frame)
      production = super
      capping = (capacity * @capping_fraction.to_f).abs

      production > capping ? capping : production
    end

    def store(_frame, _amount)
    end
  end # ConservingProducer
end # Network
