module Network
  # Given an array containing Path or TechnologyPath instances, ensures that the
  # paths are returned in the order specified.
  #
  # The Collection should be created with an array of procs; those paths for
  # which the first proc returns true are ordered at the beginning of the
  # collection, followed by those for whom the second proc is truthy, and so on.
  #
  # Any paths which do not result in a truthy value from any of the procs will
  # be placed at the end of the collection.
  class PathCollection
    include Enumerable

    def initialize(paths, order = [])
      @paths = paths
      @order = order
    end

    def each(&block)
      ordered.each(&block)
    end

    private

    def ordered
      @ordered ||=
        @paths.sort_by do |path|
          @order.map { |callable| callable.call(path) || Float::INFINITY }
        end.freeze
    end
  end
end
