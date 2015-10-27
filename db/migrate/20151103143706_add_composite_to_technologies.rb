class AddCompositeToTechnologies < ActiveRecord::Migration
  def change
    add_column :technologies, :composite, :boolean, after: :visible, default: false
  end
end
