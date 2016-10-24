class AddCentralHeatBufferCapacityAttribute < ActiveRecord::Migration
  def change
    add_column :testing_grounds, :central_heat_buffer_capacity, :float,
      after: :behavior_profile_id
  end
end
