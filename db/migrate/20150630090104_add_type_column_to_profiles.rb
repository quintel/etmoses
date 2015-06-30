class AddTypeColumnToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :type, :string, after: :id
  end
end
