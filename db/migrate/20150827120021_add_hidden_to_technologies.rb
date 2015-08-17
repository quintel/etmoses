class AddHiddenToTechnologies < ActiveRecord::Migration
  def change
    add_column :technologies, :visible, :boolean, after: :behavior, default: true
  end
end
