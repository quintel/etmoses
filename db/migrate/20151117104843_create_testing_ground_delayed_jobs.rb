class CreateTestingGroundDelayedJobs < ActiveRecord::Migration
  def change
    create_table :testing_ground_delayed_jobs do |t|
      t.integer :testing_ground_id
      t.integer :job_id
      t.string :type
    end
  end
end
