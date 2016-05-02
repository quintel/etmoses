class RenameTechnologyIdsToKeys < ActiveRecord::Migration
  def change
    add_column :importable_attributes, :technology_key, :string, after: :technology_id

    ImportableAttribute.all.each do |ia|
      ia.technology_key = ia.technology.key
      ia.save
    end
  end
end
