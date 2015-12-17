class AddingDefaultVolumeAttributes < ActiveRecord::Migration
  def change
    add_column :technologies, :default_volume_in_liters, :float, after: :default_volume
    add_column :technologies, :max_bufferable_temperature, :float, after: :default_demand
  end
end
