class AddDefaultsColumns < ActiveRecord::Migration
  def change
    add_column :load_profiles, :default_capacity, :float, after: :locked
    add_column :load_profiles, :default_volume, :float, after: :default_capacity
    add_column :load_profiles, :default_demand, :float, after: :default_volume
    add_column :technologies, :default_capacity, :float, after: :behavior
    add_column :technologies, :default_volume, :float, after: :default_capacity
    add_column :technologies, :default_demand, :float, after: :default_volume
  end
end
