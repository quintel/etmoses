module Network
  # Describes a path from a technology on an endpoint to a parent node. This may
  # be the route from the technology to the owner node, or any ancestor node
  # thereof (including the network head node).
  class SubPath < TechnologyPath
    extend Forwardable

    def_delegators :@full_path, :consume, :received_conditional_at?, :receipts

    # Public: Given a TechnologyPath which describes the path from a technology
    # to the network head, returns an array of all subpaths from the technology
    # to the ancestor nodes.
    #
    # Returns an array of TechnologyPath instances.
    def self.from(full_path)
      path   = full_path.to_a
      length = path.length - 1

      subpaths = length.times.map do |iter|
        new(Path.new(path[0...(iter + 1)]), full_path)
      end

      subpaths.push(full_path)
      subpaths
    end

    # Public: The original path from the technology to the graph head.
    attr_reader :full_path

    def initialize(sub_path, full_path)
      super(full_path.technology, sub_path)

      @full_path = full_path
      @flexible  = false
    end

    def distance
      @full_path.length - length
    end

    def subpath?
      true
    end
  end # SubPath
end
