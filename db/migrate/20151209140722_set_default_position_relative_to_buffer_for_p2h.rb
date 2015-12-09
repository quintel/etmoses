class SetDefaultPositionRelativeToBufferForP2h < ActiveRecord::Migration
  def change
    Technology.find_by_key('households_flexibility_p2h_electricity')
              .update_attribute(:default_position_relative_to_buffer, 'buffering')
  end
end
