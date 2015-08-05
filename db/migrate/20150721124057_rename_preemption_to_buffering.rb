class RenamePreemptionToBuffering < ActiveRecord::Migration
  def up
    Technology.where(behavior: 'buffer').update_all(behavior: 'optional_buffer')
    Technology.where(behavior: 'preemptive').update_all(behavior: 'buffer')
  end

  def down
    Technology.where(behavior: 'buffer').update_all(behavior: 'preemptive')
    Technology.where(behavior: 'optional_buffer').update_all(behavior: 'buffer')
  end
end
