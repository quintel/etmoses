class UpdateTechnologyCapacities < ActiveRecord::Migration
  def change
    capacities = {
      households_space_heater_network_gas: 27.5,
      households_space_heater_combined_network_gas:  20.6185567,
      households_water_heater_network_gas: 35.8208955,
      households_water_heater_combined_network_gas: 24.4444444,
      households_space_heater_hybrid_heatpump_air_water_electricity_electricity: 1.0888889,
      households_space_heater_hybrid_heatpump_air_water_electricity_gas: 20.6185567,
      households_water_heater_hybrid_heatpump_air_water_electricity_electricity: 1.6333333,
      households_water_heater_hybrid_heatpump_air_water_electricity_gas: 24.4444444,
      energy_flexibility_p2g_electricity: 739.5833333
    }

    Technology.where(key: capacities.keys).each do |technology|
      technology.update_attribute(:default_capacity,
                                  capacities[technology.key.to_sym])
    end
  end
end
