module GasAssetLists
  class CumulativeInvestmentCalculator < Calculator
    def calculate
      total = 0
      time_range.map.each_with_object({}) do |year, result|
        total += (gas_assets_by_year[year] || []).sum(&:total_investment_costs)

        result[year] = total
      end
    end

    private

    def min_year
      @gas_asset_list.map(&:decommissioning_year).min
    end

    def gas_assets_by_year
      @gas_asset_list.group_by(&:decommissioning_year)
    end
  end
end
