module Finance
  class BusinessCaseCalculator
    module StakeholderFetcher
      def fetch_stakeholders
        (topology_stakeholders.compact +
         gas_asset_list_stakeholders +
         market_model_stakeholders.flatten).uniq.sort
      end

      private

      def topology_stakeholders
        networks[:electricity].nodes.map{ |n| n.get(:stakeholder) }
      end

      def market_model_stakeholders
        @testing_ground.market_model.interactions.map do |interaction|
          interaction.slice("stakeholder_from", "stakeholder_to").values
        end
      end

      def gas_asset_list_stakeholders
        return [] unless @testing_ground.gas_asset_list

        @testing_ground.gas_asset_list.asset_list.map do |asset|
          asset[:stakeholder]
        end
      end
    end
  end
end
