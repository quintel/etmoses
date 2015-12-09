class FlattenHeatPumpCategory < ActiveRecord::Migration
  def change
    heat_pump = LoadProfileCategory.find_by_name("Heat pumps")

    LoadProfileCategory.where(parent_id: heat_pump.id).update_all(parent_id: 1)

    heat_pump.destroy
  end
end
