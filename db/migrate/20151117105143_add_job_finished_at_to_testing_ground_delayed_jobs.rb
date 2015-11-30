class AddJobFinishedAtToTestingGroundDelayedJobs < ActiveRecord::Migration
  def change
    add_column :testing_ground_delayed_jobs, :finished_at, :datetime, before: :type
    rename_column :testing_ground_delayed_jobs, :type, :job_type
  end
end
