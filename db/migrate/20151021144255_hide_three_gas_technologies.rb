class HideThreeGasTechnologies < ActiveRecord::Migration
  def change
    Technology.where(key: [
      "households_space_heater_micro_chp_network_gas",
      "households_water_heater_micro_chp_network_gas",
      "households_water_heater_fuel_cell_chp_network_gas"
    ]).update_all(visible: false)
  end
end
