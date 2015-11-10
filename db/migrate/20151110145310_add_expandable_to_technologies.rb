class AddExpandableToTechnologies < ActiveRecord::Migration
  def change
    add_column :technologies, :expandable, :boolean, default: true
  end
end
