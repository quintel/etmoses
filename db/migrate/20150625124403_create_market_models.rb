class CreateMarketModels < ActiveRecord::Migration
  def change
    create_table :market_models do |t|
      t.string :name
      t.integer :user_id
      t.text :interactions
      t.timestamps
    end

    create_table :stakeholders do |t|
      t.string :name
      t.timestamps
    end
  end
end
