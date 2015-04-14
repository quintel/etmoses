module Calculation
  class LocalStorage
    # Public: Determines the behaviour of storage batteries during the year, and
    # calculates loads.
    #
    # context - The Calculation::Context containing the graph and technologies.
    #
    # Returns the context.
    def self.call(context)
      new(context).run
    end

    # Internal: Creates a new LocalStorage calculator.
    def initialize(context)
      @context = context
    end

    # Internal: Runs the LocalStorage calculator. Determines the load on each
    # battery in each time-step.
    def run
      storage_tech_nodes.each do |node|
        stores = node.get(:techs).select(&:storage?)

        @context.points do |point|
          if (deficit = node.local_load_at(point)) > 0
            discharge!(stores, deficit, point)
          elsif deficit < 0
            charge!(stores, -deficit, point)
          end
        end
      end

      @context
    end

    #######
    private
    #######

    # Internal: The timestep being calculated has a deficit of energy. Discharge
    # the batteries until the deficit is eliminated, or all the batteries are
    # empty.
    def discharge!(stores, deficit, point)
      stores.each do |store|
        load_from_store = min(deficit, store.stored_at(point))

        store.load[point] = -load_from_store
        deficit           -= load_from_store
      end
    end

    # Internal: The timestep being calculated has a surplus of energy. Charge
    # the batteries until the surplus is eliminated, or all the batteries are
    # full.
    def charge!(stores, excess, point)
      stores.each do |store|
        load_for_store = min(excess, store.headroom_at(point))

        store.load[point] = load_for_store
        excess           -= load_for_store
      end
    end

    # Internal: Returns all nodes which have one or more storage technology.
    def storage_tech_nodes
      @context.technology_nodes.select do |node|
        node.get(:techs).any? { |t| t.storage? }
      end
    end

    # Internal: A simple helper which returns the minimum of two values. Better
    # than creating an extra array and then calling Array#min, and clearer than
    # assigning both to varibles and comparing.
    #
    # Returns the minimum of the two values.
    def min(v1, v2)
      v1 < v2 ? v1 : v2
    end
  end
end
