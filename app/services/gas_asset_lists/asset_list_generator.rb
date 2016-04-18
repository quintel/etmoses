module GasAssetLists
  class AssetListGenerator
    GQUERY_KEY = 'turk_number_of_households'
    DEFAULT_BUILDING_YEAR = 1960

    def initialize(testing_ground)
      @testing_ground = testing_ground
    end

    def generate
      (GasAssets::Pipe.all + GasAssets::Connector.all).inject([]) do |result, part|
        result + part.pressure_levels.map do |pressure_level|
          InstalledGasAsset.new(
            create_gas_asset(part, pressure_level)).attributes
        end
      end
    end

    private

    def create_gas_asset(part, pressure_level)
      pressure_level_index = GasAssetList::PRESSURE_LEVELS.index(pressure_level)
      amount_for_asset = default_amounts[part.type][pressure_level.to_s]

      GasAssetList::DEFAULT.merge(part.attributes).merge(
        part: part.part_type.pluralize,
        amount: amount_for_asset * fraction,
        pressure_level_index: pressure_level_index
      )
    end

    def fraction
      amount_of_gas_technologies.to_f / total_amount_of_households
    end

    def amount_of_gas_technologies
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

    # Grabs the total amount of households from the parent scenario
    #
    # Returns a Float
    def total_amount_of_households
      @total_amount_of_households ||= begin
        EtEngineConnector.new(gqueries: [GQUERY_KEY])
          .gquery(@testing_ground.parent_scenario_id)
          .fetch(GQUERY_KEY)
          .fetch('present')
      end
    end

    # Grab the default amounts for gas assets per pressure level
    #
    # Returns a Hash
    def default_amounts
      @default_amounts ||= YAML.load(
        File.read("#{Rails.root}/db/static/gas_asset_defaults.yml")
      ).fetch(DEFAULT_BUILDING_YEAR)
    end
  end
end
