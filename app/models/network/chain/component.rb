module Network
  module Chain
    # Part of the chain network.
    module Component
      def initialize
        super

        @children ||= Set.new
        @load = []
      end

      # Public: Determines the load on this component in the given `frame`.
      #
      # Returns a numeric.
      def call(frame)
        @load[frame] ||= @children.sum(0.0) { |child| child.call(frame) }
      end

      # Public: A set containing lower-level components.
      #
      # Returns a Set[Component].
      def children
        @children
      end

      # Public: Connects the given `child` as a child of this component.
      #
      # Returns self.
      def connect_to(child)
        @children.add(child)
        self
      end
    end # Component
  end # Chain
end
