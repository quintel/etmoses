module ETLoader
  class Calculator
    def initialize(graph)
      @graph = graph
    end

    def calculate
      @graph.nodes
        .select { |n| n.out.to_a.empty? }
        .each(&method(:calculate_node))

      @graph
    end

    #######
    private
    #######

    def calculate_node(node)
      node.set(:calculated, true)

      node.set(:demand, node.get(:technologies).values
        .map(&:demand).compact.reduce(:+))

      node.in.
        reject { |n| n.get(:calculated) }.
        each(&method(:calculate_node))
    end
  end # Calculator
end # ETLoader
