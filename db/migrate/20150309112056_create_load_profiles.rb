class CreateLoadProfiles < ActiveRecord::Migration
  def change
    create_table :load_profiles do |t|
      t.string     :key,    null: false
      t.string     :name
      t.boolean    :locked, null: false, default: false
      t.attachment :curve
      t.timestamps
    end

    add_index :load_profiles, :key, unique: true
  end
end
