class AddDefaultBufferingOrBoostingToTechnologies < ActiveRecord::Migration
  def change
    boosting = %w(
       households_space_heater_network_gas
       households_space_heater_combined_network_gas
       households_water_heater_network_gas
       households_water_heater_combined_network_gas)
    buffering = %w(
       households_space_heater_heatpump_air_water_electricity
       households_space_heater_heatpump_ground_water_electricity
       households_water_heater_heatpump_air_water_electricity
       households_water_heater_heatpump_ground_water_electricity)

    Technology.where(key: buffering).update_all(default_position_relative_to_buffer: 'buffering')
    Technology.where(key: boosting).update_all(default_position_relative_to_buffer: 'boosting')
  end
end
