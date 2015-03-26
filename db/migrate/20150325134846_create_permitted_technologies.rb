class CreatePermittedTechnologies < ActiveRecord::Migration
  def change
    create_table :permitted_technologies do |t|
      t.integer :load_profile_id, null: false
      t.string  :technology,      null: false
    end

    add_index :permitted_technologies,  :load_profile_id
    add_index :permitted_technologies, [:load_profile_id, :technology], unique: true

    add_column :load_profiles, :capacity_group, :string
    add_column :load_profiles, :min_capacity,   :float
  end
end
