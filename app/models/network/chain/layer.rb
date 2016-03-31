module Network
  module Chain
    # Describes a layer within a chain network. Layers are joined by Connections
    # which flow energy from the bottom of the network to the top, observing
    # capacity constraints and efficiency along the way.
    class Layer
      include Component
    end # Layer
  end # Chain
end
