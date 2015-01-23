module ETLoader
  class Calculator
    def initialize(graph)
      @graph = graph
    end

    def refinery_graph
      @refinery ||= Refinery::Catalyst::FromTurbine.call(@graph)
    end

    def calculate
      Refinery::Catalyst::Calculators.call(refinery_graph)
    end
  end # Calculator
end # ETLoader
