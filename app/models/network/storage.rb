module Network
  # A technology which, instead of producing or consuming energy, may do either
  # depending on the load of the network. Storage may retain consumed energy for
  # release back to the network later.
  class Storage < Technology
    def load_at(point)
      load[point] || 0.0
    end

    def production_at(point)
      stored_at(point)
    end

    def mandatory_consumption_at(point)
      0.0
    end

    def conditional_consumption_at(point)
      installed.storage
    end

    def load
      @load ||= []
    end

    def stored_at(point)
      if point < 0
        0.0
      else
        stored[point] ||= stored_at(point - 1) + load_at(point - 1)
      end
    end

    def storage?
      true
    end

    # Public: Returns how much of the technology's capacity remains unused.
    def headroom_at(point)
      installed.storage - stored_at(point)
    end

    #######
    private
    #######

    def stored
      @storage ||= []
    end
  end
end
