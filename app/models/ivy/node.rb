module Ivy
  class Node < Turbine::Node
    def load
      get(:load) || set(:load, [])
    end

    def load_at(point)
      load[point] ||= begin
        tech_load  = flow_at(point)
        child_load = memoized_out.sum { |child| child.load_at(point) }

        tech_load + child_load
      end
    end

    def flow_at(point)
      (techs = get(:techs)) ? techs.sum { |tech| tech.flow_at(point) } : 0.0
    end

    def set_load(point, value)
      load[point] = value
    end

    def memoized_out
      get(:memoized_out) || set(:memoized_out, nodes(:out))
    end
  end # Node
end # Ivy
