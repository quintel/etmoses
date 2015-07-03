module Network
  # A production technology which should reduce its production in the event of
  # an excess of production in the network.
  class ConservingProducer < Technology
    extend Disableable

    def self.disabled?(options)
      ! options[:flexibility]
    end

    def self.disabled_class
      Technology
    end

    def conditional_consumption_at(frame)
      production_at(frame)
    end

    def store(_frame, _amount)
    end
  end # ConservingProducer
end # Network
