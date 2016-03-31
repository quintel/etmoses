module GasAssets
  class Base < ActiveHash::Base
    def self.where_pressure(pressure_level)
      all.select do |asset|
        (asset.pressure_levels.map(&:to_f) || []).include?(pressure_level.to_f)
      end
    end
  end
end
