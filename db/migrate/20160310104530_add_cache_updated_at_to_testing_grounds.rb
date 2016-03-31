class AddCacheUpdatedAtToTestingGrounds < ActiveRecord::Migration
  def change
    add_column :testing_grounds, :cache_updated_at, :datetime, after: :updated_at
  end
end
