class FixNullGasAssetPressureLevels < ActiveRecord::Migration
  def up
    changes = 0

    GasAssetList.find_each do |list|
      previous_changes = changes

      list.asset_list = list.asset_list.map do |asset|
        if asset['pressure_level_index'].nil?
          asset['pressure_level_index'] = 0
          changes += 1
        end

        asset
      end

      list.save(validate: false) if changes != previous_changes
    end

    say "Fixed assets in #{ changes } lists"
  end

  def down
  end
end
