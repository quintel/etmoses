class AddDefaultCapacityAndDefaultVolumeToBuffers < ActiveRecord::Migration
  def change
    bsh = Technology.find_by_key("buffer_space_heating")
    bsh.update_attributes(default_capacity: 10.0, default_volume: 4.6504)

    bwh = Technology.find_by_key("buffer_water_heating")
    bwh.update_attributes(default_capacity: 10.0, default_volume: 5.813)

    heat_pumps = %w(
      households_space_heater_heatpump_air_water_electricity
      households_space_heater_heatpump_ground_water_electricity
      households_water_heater_heatpump_air_water_electricity
      households_water_heater_heatpump_ground_water_electricity
    )

    Technology.where(key: heat_pumps).update_all(default_volume: nil)
  end
end
