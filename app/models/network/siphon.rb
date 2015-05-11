module Network
  # Consumes excess energy from the testing ground, with the profile defining
  # the maximum amount which may be consumed. If there is no excess, the Siphon
  # will be turned off and will receive nothing.
  class Siphon < Technology
    def load_at(frame)
      conditional_consumption_at(frame)
    end

    def mandatory_consumption_at(_frame)
      0.0
    end

    def conditional_consumption_at(frame)
      @profile.at(frame)
    end
  end # Siphon
end # Network
