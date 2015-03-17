class AddNameToTestingGrounds < ActiveRecord::Migration
  def up
    add_column :testing_grounds, :name, :string, null: false, limit: 100

    TestingGround.find_each do |tg|
      tg.update_attributes!(
        name: "Testing ground #{ tg.created_at.to_formatted_s(:long) }")
    end
  end

  def down
    remove_column :testing_grounds, :name, :string, null: false
  end
end
