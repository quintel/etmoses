class CreatingInitialGasTechnologies < ActiveRecord::Migration
  def change
    %w(households_space_heater_network_gas households_space_heater_combined_network_gas
       households_space_heater_micro_chp_network_gas households_water_heater_network_gas
       households_water_heater_combined_network_gas households_water_heater_micro_chp_network_gas
       households_water_heater_fuel_cell_chp_network_gas).each do |technology|
      Technology.create!(key: technology, name: technology.humanize, visible: 1)
    end
  end
end
