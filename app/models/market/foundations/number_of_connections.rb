module Market::Foundations
  # Given a node, determines the number of discrete connections present in the
  # node.
  module NumberOfConnections
    CONNECTION_TECHS = %w( base_load base_load_buildings ).freeze

    def self.call(node)
      node.techs.sum do |tech|
        if CONNECTION_TECHS.include?(tech.installed.type)
          tech.installed.units
        else
          0
        end
      end
    end
  end # NumberOfConnections
end # Market::Foundations
