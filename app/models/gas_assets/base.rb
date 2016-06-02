module GasAssets
  class Base < ActiveHash::Base
    PRESSURE_LEVELS = {
      "125_mbar" => 0.125,
      "4_bar"    => 4,
      "8_bar"    => 8,
      "40_bar"   => 40
    }.freeze

    def self.where_pressure(pressure_level_index)
      all.select do |asset|
        asset.pressure_level == PRESSURE_LEVELS.values[pressure_level_index.to_i]
      end
    end

    def pressure_level_indexes
      pressure_levels.map do |pressure_level|
        GasAssetList::PRESSURE_LEVELS.index(pressure_level)
      end
    end

    def direction
    end
  end
end
