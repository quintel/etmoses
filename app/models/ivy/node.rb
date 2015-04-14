module Ivy
  class Node < Turbine::Node
    def load
      get(:load) || set(:load, [])
    end

    def load_at(point)
      load[point] ||=
        local_load_at(point) + memoized_out.sum { |child| child.load_at(point) }
    end

    def set_load(point, value)
      load[point] = value
    end

    # Public: Returns the deficit or surplus of energy of the node based only on
    # the technologies assigned to it.
    def local_load_at(point)
      (techs = get(:techs)) ? techs.sum { |tech| tech.load_at(point) } : 0.0
    end

    #######
    private
    #######

    # Internal: A memoized list of child nodes. Since the graph never changes
    # during calculation, this is faster then getting the a fresh child list
    # in each time step.
    def memoized_out
      @memoized_out ||= nodes(:out)
    end
  end # Node
end # Ivy
