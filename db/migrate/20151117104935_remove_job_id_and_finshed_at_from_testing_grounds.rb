class RemoveJobIdAndFinshedAtFromTestingGrounds < ActiveRecord::Migration
  def change
    remove_column :testing_grounds, :job_id
    remove_column :testing_grounds, :job_finished_at
  end
end
