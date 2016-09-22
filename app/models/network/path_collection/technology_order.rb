module Network
  class PathCollection
    class TechnologyOrder
      def initialize(matchers)
        @matchers = matchers
        @remnants = @matchers[(@matchers.index(:rest) + 1)..-1]
      end

      def call(path)
        @matchers.index do |klass|
          if klass == :rest
            @remnants.all? { |k| ! path.technology.is_a?(k) }
          else
            path.technology.is_a?(klass)
          end
        end
      end
    end # TechnologyOrder
  end # PathCollection
end
