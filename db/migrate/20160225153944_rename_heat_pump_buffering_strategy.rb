class RenameHeatPumpBufferingStrategy < ActiveRecord::Migration
  def change
    rename_column :selected_strategies,
      :buffering_space_heating, :hp_capacity_constrained
  end
end
