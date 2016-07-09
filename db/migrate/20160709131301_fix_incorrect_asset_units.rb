class FixIncorrectAssetUnits < ActiveRecord::Migration
  def up
    fix_units!(1000.0)
  end

  def down
    fix_units!(1 / 1000.0)
  end

  private

  def fix_units!(multiplier)
    HeatSourceList.find_each do |list|
      list.asset_list = list.asset_list.map do |item|
        item = item.symbolize_keys

        if item[:heat_production].present?
          production = item[:heat_production].to_f

          if multiplier > 1
            item[:heat_production] = production * (1 / 3.6).round(1) # MJ to kWh
          else
            item[:heat_production] = production / (1 / 3.6) # kWh to MJ
          end
        end

        if item[:heat_capacity].present?
          item[:heat_capacity] =
            (item[:heat_capacity].to_f * multiplier).round(1)
        end

        if item[:marginal_heat_costs].present?
          item[:marginal_heat_costs] =
            (item[:marginal_heat_costs].to_f / multiplier).round(4)
        end

        item.stringify_keys
      end

      list.save!
    end
  end
end
