module Market
  class Stakeholder < Turbine::Node
    # Public: Connects this node to another.
    #
    # See Turbine::Node#connect_to
    #
    # Returns the Market::Relation which was created.
    #
    # Raises a Turbine::DuplicateEdgeError if the Edge already existed.
    def connect_to(target, label = nil, properties = nil)
      Relation.new(self, target, label, properties).tap do |edge|
        self.connect_via(edge)
        target.connect_via(edge)
      end
    end
  end
end
