class AddImportableAttributesForTechnologies < ActiveRecord::Migration
  def change
    change_column :importable_attributes, :name, :string, limit: 100

    Technology.where("`key` NOT LIKE 'base_load%' AND `key` != 'generic'").all.map do |technology|
      %w(fixed_operation_and_maintenance_costs_per_year
         variable_operation_and_maintenance_costs_for_ccs_per_full_load_hour
         variable_operation_and_maintenance_costs_per_full_load_hour
         full_load_hours).each do |attr|

        technology.importable_attributes.create(name: attr)
      end
    end
  end
end
