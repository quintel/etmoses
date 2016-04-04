class RemoveTechnologiesFromConcurrencyList < ActiveRecord::Migration
  def change
    techs = %w(households_space_heater_heatpump_air_water_electricity
               households_space_heater_heatpump_ground_water_electricity
               households_water_heater_heatpump_air_water_electricity
               households_water_heater_heatpump_ground_water_electricity
               households_flexibility_p2h_electricity
               generic)

    Technology.where(key: techs).update_all(expandable: false)
  end
end
