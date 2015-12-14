class SetBehaviorOfHhpTechnologies < ActiveRecord::Migration
  ELECTRICITY_TECHS = %w(
    households_space_heater_hybrid_heatpump_air_water_electricity_electricity
    households_water_heater_hybrid_heatpump_air_water_electricity_electricity
  )

  GAS_TECHS = %w(
    households_space_heater_hybrid_heatpump_air_water_electricity_gas
    households_water_heater_hybrid_heatpump_air_water_electricity_gas
  )

  NULL_TECHS = %w(
    households_space_heater_hybrid_heatpump_air_water_electricity
    households_water_heater_hybrid_heatpump_air_water_electricity
  )

  def change
    Technology.where(key: ELECTRICITY_TECHS).update_all(behavior: 'hhp_electricity')
    Technology.where(key: GAS_TECHS).update_all(behavior: 'hhp_gas')
    Technology.where(key: NULL_TECHS).update_all(behavior: 'null')
  end
end
