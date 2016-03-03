class RemoveFinishedAtColumnFromTestingGroundDelayedJobs < ActiveRecord::Migration
  def change
    remove_column :testing_ground_delayed_jobs, :finished_at
  end
end
