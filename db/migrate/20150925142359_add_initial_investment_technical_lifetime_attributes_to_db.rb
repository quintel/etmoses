class AddInitialInvestmentTechnicalLifetimeAttributesToDb < ActiveRecord::Migration
  def change
    techs = %w(
      energy_flexibility_p2g_electricity
      households_flexibility_p2h_electricity
      households_flexibility_p2p_electricity
      households_solar_pv_solar_radiation
      households_space_heater_heatpump_air_water_electricity
      households_space_heater_heatpump_ground_water_electricity
      households_water_heater_heatpump_air_water_electricity
      households_water_heater_heatpump_ground_water_electricity
    )

    Technology.where(key: techs).map do |technology|
      technology.importable_attributes.create(name: 'initial_investment')
      technology.importable_attributes.create(name: 'technical_lifetime')
    end
  end
end
