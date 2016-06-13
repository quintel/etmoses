module GasAssetLists
  class AssetListGenerator
    GQUERY_KEY = 'turk_number_of_households'
    DEFAULT_BUILDING_YEAR = 1960

    def initialize(testing_ground)
      @testing_ground = testing_ground
    end

    def generate
      GasAssets::Base.all_assets.map do |part|
        InstalledGasAsset.new(create_gas_asset(part)).attributes
      end
    end

    private

    def create_gas_asset(part)
      pressure_level_index = GasAssetList::PRESSURE_LEVELS.index(part.pressure_level)

      GasAssetListDecorator::DEFAULT.merge(part.attributes).merge(
        part: part.part_type.pluralize,
        amount: (part.default_amount * amount_of_gas_connections).round(3),
        pressure_level_index: pressure_level_index
      )
    end

    def amount_of_gas_connections
      network(:electricity).nodes.sum do |node|
        if gas_network_keys.include?(node.key)
          Market::Measures::NumberOfConnections.call(node)
        else
          0
        end
      end
    end

    # Returns a set of network keys
    def gas_network_keys
      @gas_network_keys ||= network(:gas).nodes.map(&:key)
    end

    # Initializes a Network::Builder object based of the carrier
    # Set's all the techs without any validation.
    #
    # Returns a Network::Builder
    def network(carrier)
      network = Network::Builders.for(carrier).build(
        @testing_ground.topology.graph, @testing_ground.technology_profile)

      network.nodes.each do |node|
        node.set(:techs, node.get(:installed_techs).map do |tech|
          OpenStruct.new(installed: tech)
        end)
      end

      network
    end
  end
end
