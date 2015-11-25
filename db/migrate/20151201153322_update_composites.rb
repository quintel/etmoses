class UpdateComposites < ActiveRecord::Migration
  def change
    buffer_space_heating            = Technology.find_by_key("buffer_space_heating")
    network_gas_technology          = Technology.find_by_key("households_space_heater_network_gas")
    network_combined_gas_technology = Technology.find_by_key("households_space_heater_combined_network_gas")

    Composite.create!(composite: buffer_space_heating, technology: network_gas_technology)
    Composite.create!(composite: buffer_space_heating, technology: network_combined_gas_technology)
  end
end
