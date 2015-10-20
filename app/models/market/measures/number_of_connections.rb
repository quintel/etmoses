module Market::Measures
  # Given a node, determines the number of discrete connections present in the
  # node.
  module NumberOfConnections
    CONNECTION_TECHS = %w( base_load base_load_edsn base_load_buildings ).freeze

    def self.call(node)
      node.techs.map(&:installed).uniq.sum do |installed|
        if CONNECTION_TECHS.include?(installed.type)
          installed.units
        else
          0
        end
      end
    end

    def self.irregular?
      true
    end
  end
end
