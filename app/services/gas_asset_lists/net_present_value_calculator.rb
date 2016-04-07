module GasAssetLists
  class NetPresentValueCalculator < Base
    def calculate
      time_range.map.each_with_object({}) do |year, result|
        result[year] = @gas_asset_list.sum do |gas_asset|
          gas_asset.net_present_value_at(year) * gas_asset.amount
        end
      end
    end
  end
end
