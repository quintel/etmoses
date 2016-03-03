class AddRangeStartRangeEndForTestingGrounds < ActiveRecord::Migration
  def change
    add_column :testing_grounds, :range_start, :integer, default: 0
    add_column :testing_grounds, :range_end, :integer, default: 672
  end
end
