class AddHhpToTechnologies < ActiveRecord::Migration
  def change
    # Space
    Technology.create!({
      key: 'households_space_heater_hybrid_heatpump_air_water_electricity',
      name: "Hybrid heat pump space heating (electricity)",
      carrier: "electricity",
      default_capacity: 4.9,
      default_position_relative_to_buffer: "buffering"
    })

    Technology.create!({
      key: 'households_space_heater_hybrid_heatpump_air_water_electricity',
      name: "Hybrid heat pump space heating (gas)",
      carrier: "gas",
      default_capacity: 15.0,
      default_position_relative_to_buffer: "boosting"
    })

    # Water
    Technology.create!({
      key: 'households_water_heater_hybrid_heatpump_air_water_electricity',
      name: "Hybrid heat pump hot water (electricity)",
      carrier: "electricity",
      default_capacity: 4.9,
      default_position_relative_to_buffer: "buffering"
    })

    Technology.create!({
      key: 'households_water_heater_hybrid_heatpump_air_water_electricity',
      name: "Hybrid heat pump space heating (gas)",
      carrier: "gas",
      default_capacity: 15.0,
      default_position_relative_to_buffer: "boosting"
    })
  end
end
