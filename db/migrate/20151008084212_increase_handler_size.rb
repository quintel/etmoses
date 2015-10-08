class IncreaseHandlerSize < ActiveRecord::Migration
  def change
    change_column :delayed_jobs, :handler, :text, :limit => 64.kilobytes + 1
  end
end
