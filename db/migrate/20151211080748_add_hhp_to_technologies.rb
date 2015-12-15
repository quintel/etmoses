class AddHhpToTechnologies < ActiveRecord::Migration
  def change
    # Space
    hhp_sh = Technology.create!({
      key: 'households_space_heater_hybrid_heatpump_air_water_electricity',
      name: "Hybrid heat pump space heating",
      carrier: "hybrid",
      visible: false
    })

      Technology.create!({
        key: 'households_space_heater_hybrid_heatpump_air_water_electricity_electricity',
        name: "Hybrid heat pump space heating (electricity)",
        carrier: "electricity",
        default_capacity: 4.9,
        default_position_relative_to_buffer: "buffering"
      })

      Technology.create!({
        key: 'households_space_heater_hybrid_heatpump_air_water_electricity_gas',
        name: "Hybrid heat pump space heating (gas)",
        carrier: "gas",
        default_capacity: 15.0,
        default_position_relative_to_buffer: "boosting"
      })

    # Water
    hhp_wh = Technology.create!({
      key: 'households_water_heater_hybrid_heatpump_air_water_electricity',
      name: "Hybrid heat pump hot water",
      carrier: "hybrid",
      visible: false
    })

      Technology.create!({
        key: 'households_water_heater_hybrid_heatpump_air_water_electricity_electricity',
        name: "Hybrid heat pump hot water (electricity)",
        carrier: "electricity",
        default_capacity: 4.9,
        default_position_relative_to_buffer: "buffering"
      })

      Technology.create!({
        key: 'households_water_heater_hybrid_heatpump_air_water_electricity_gas',
        name: "Hybrid heat pump hot water (gas)",
        carrier: "gas",
        default_capacity: 15.0,
        default_position_relative_to_buffer: "boosting"
      })

    # Attributes for hhp
    %w(initial_investment
       full_load_hours
       coefficient_of_performance
       technical_lifetime
       fixed_operation_and_maintenance_costs_per_year
       variable_operation_and_maintenance_costs_per_full_load_hour
       variable_operation_and_maintenance_costs_for_ccs_per_full_load_hour).each do |attribute|
         ImportableAttribute.create!(technology: hhp_wh, name: attribute)
         ImportableAttribute.create!(technology: hhp_sh, name: attribute)
       end
  end
end
