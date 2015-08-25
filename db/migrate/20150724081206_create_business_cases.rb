class CreateBusinessCases < ActiveRecord::Migration
  def change
    create_table :business_cases do |t|
      t.integer :testing_ground_id
      t.text :financials
      t.timestamps
    end
  end
end
