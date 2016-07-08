module Finance
  class BusinessCaseCalculator
    module StakeholderFetcher
      def fetch_stakeholders
        ( asset_list_stakeholders(:gas_asset_list) +
          asset_list_stakeholders(:heat_source_list) +
          asset_list_stakeholders(:heat_asset_list) +
          market_model_stakeholders +
          topology_stakeholders
        ).compact.uniq.sort
      end

      private

      def topology_stakeholders
        networks[:electricity].nodes.map{ |n| n.get(:stakeholder) }.compact
      end

      def market_model_stakeholders
        @testing_ground.market_model.interactions.flat_map do |interaction|
          interaction.slice('stakeholder_from', 'stakeholder_to').values
        end
      end

      def asset_list_stakeholders(asset_list)
        return [] unless @testing_ground.public_send(asset_list)

        @testing_ground.public_send(asset_list).asset_list.map do |asset|
          asset[:stakeholder]
        end
      end
    end
  end
end
