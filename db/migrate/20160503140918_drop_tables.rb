class DropTables < ActiveRecord::Migration
  def change
    drop_table :composites
    drop_table :importable_attributes
    drop_table :technology_component_behaviors
    drop_table :technologies
  end
end
