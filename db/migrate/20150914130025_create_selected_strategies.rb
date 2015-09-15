class CreateSelectedStrategies < ActiveRecord::Migration
  def change
    create_table :selected_strategies do |t|
      t.belongs_to :testing_ground
      t.boolean :solar_storage, default: false
      t.boolean :battery_storage, default: false
      t.boolean :solar_power_to_heat, default: false
      t.boolean :solar_power_to_gas, default: false
      t.boolean :buffering_electric_car, default: false
      t.boolean :buffering_space_heating, default: false
      t.boolean :postponing_base_load, default: false
      t.boolean :saving_base_load, default: false
      t.boolean :capping_solar_pv, default: false
      t.float :capping_fraction, default: 1.0
    end
  end
end
