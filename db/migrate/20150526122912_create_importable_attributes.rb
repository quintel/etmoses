class CreateImportableAttributes < ActiveRecord::Migration
  def up
    create_table :importable_attributes do |t|
      t.integer :technology_id, null: :false
      t.string :name, limit: 50, null: :false

      t.index [:technology_id, :name], unique: true
    end

    ImportableAttribute.reset_column_information

    Technology.where.not(import_from: nil).find_each do |technology|
      ImportableAttribute.create!(
        technology: technology,
        name: technology.import_from
      )
    end

    remove_column :technologies, :import_from
  end

  def down
    add_column :technologies, :import_from, :string, limit: 50, after: :name
    Technology.reset_column_information

    ImportableAttribute.find_each do |attribute|
      attribute.technology.update_attributes!(import_from: attribute.name)
    end

    drop_table :importable_attributes
  end
end
