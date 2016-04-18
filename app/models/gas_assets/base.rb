module GasAssets
  class Base < ActiveHash::Base
    def self.where_pressure(pressure_level_index)
      all.select do |asset|
        (asset.pressure_level_indexes || []).include?(pressure_level_index.to_i)
      end
    end

    def pressure_level_indexes
      pressure_levels.map do |pressure_level|
        GasAssetList::PRESSURE_LEVELS.index(pressure_level)
      end
    end
  end
end
