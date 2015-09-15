class AddJobIdAndJobFinishedAtToTestingGrounds < ActiveRecord::Migration
  def change
    add_column :testing_grounds, :job_id, :integer, after: :parent_scenario_id
    add_column :testing_grounds, :job_finished_at, :datetime, after: :job_id
  end
end
