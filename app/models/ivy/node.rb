module Ivy
  class Node < Turbine::Node
    def load
      get(:load) || set(:load, [])
    end

    def load_at(point)
      load[point]
    end

    def set_load(point, value)
      load[point] = value
    end
  end # Node
end # Ivy
