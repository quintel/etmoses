module GasAssetLists
  class Calculator
    def initialize(gas_asset_list)
      @gas_asset_list = GasAssetListDecorator.new(gas_asset_list).decorate
    end

    private

    def time_range
      min_year..max_year
    end

    def min_year
      @gas_asset_list.map(&:building_year).min
    end

    def max_year
      @gas_asset_list.map(&:decommissioning_year).max
    end
  end
end
