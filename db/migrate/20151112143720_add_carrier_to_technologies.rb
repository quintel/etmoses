class AddCarrierToTechnologies < ActiveRecord::Migration
  def up
    add_column :technologies, :carrier, :string,
      limit: 32, null: false, after: :export_to

    Technology.find_each do |tech|
      tech.carrier = 'electricity'
      tech.save(validate: false)
    end
  end

  def down
    remove_column :technologies, :carrier
  end
end
