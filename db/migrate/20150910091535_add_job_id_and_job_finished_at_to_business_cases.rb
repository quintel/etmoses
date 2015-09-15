class AddJobIdAndJobFinishedAtToBusinessCases < ActiveRecord::Migration
  def change
    add_column :business_cases, :job_id, :integer, after: :financials
    add_column :business_cases, :job_finished_at, :datetime, after: :job_id
  end
end
