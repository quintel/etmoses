class AddDefaultPositionRelativeToBufferToTechnologies < ActiveRecord::Migration
  def change
    add_column :technologies, :default_position_relative_to_buffer, :string, after: :default_demand
  end
end
