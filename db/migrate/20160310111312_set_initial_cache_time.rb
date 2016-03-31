class SetInitialCacheTime < ActiveRecord::Migration
  def change
    TestingGround.all.map do |t|
      t.touch(:cache_updated_at)
    end
  end
end
