class AddImportTargetsForGas < ActiveRecord::Migration
  def change
    %w(households_space_heater_network_gas households_space_heater_combined_network_gas).map do |tech|
      t = Technology.find_by_key(tech)
      ImportableAttribute.create!(technology: t, name: 'storage.volume')
      ImportableAttribute.create!(technology: t, name: 'input_capacity')
      ImportableAttribute.create!(technology: t, name: 'technical_lifetime')
      ImportableAttribute.create!(technology: t, name: 'variable_operation_and_maintenance_costs_for_ccs_per_full_load_hour')
      ImportableAttribute.create!(technology: t, name: 'variable_operation_and_maintenance_costs_per_full_load_hour')
      ImportableAttribute.create!(technology: t, name: 'initial_investment')
    end
  end
end
