class RemoveTechnologyIdFieldFromImportableAttributes < ActiveRecord::Migration
  def change
    remove_index :importable_attributes, :technology_id_and_name
    remove_column :importable_attributes, :technology_id
  end
end
