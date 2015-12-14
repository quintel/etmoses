class MarkHhpPartsAsCompositeChildren < ActiveRecord::Migration
  def change
    buffer_space_heating = Technology.find_by_key("buffer_space_heating")
    hhp_sh_parts = %w(
      households_space_heater_hybrid_heatpump_air_water_electricity_electricity
      households_space_heater_hybrid_heatpump_air_water_electricity_gas)

    Technology.where(key: hhp_sh_parts).each do |tech|
      Composite.create!(technology_id: tech.id, composite_id: buffer_space_heating.id)
    end

    buffer_water_heating = Technology.find_by_key("buffer_water_heating")
    hhp_wh_parts = %w(
      households_water_heater_hybrid_heatpump_air_water_electricity_electricity
      households_water_heater_hybrid_heatpump_air_water_electricity_gas)

    Technology.where(key: hhp_wh_parts).each do |tech|
      Composite.create!(technology_id: tech.id, composite_id: buffer_water_heating.id)
    end
  end
end
