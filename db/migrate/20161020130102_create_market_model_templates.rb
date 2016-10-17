class CreateMarketModelTemplates < ActiveRecord::Migration
  def up
    rename_table(:market_models, :market_model_templates)

    remove_column(:market_model_templates, :original_id)

    create_table :market_models do |t|
      t.text :interactions, limit: 16_777_215, null: false
      t.belongs_to(:testing_ground)
      t.belongs_to(:market_model_template)
      t.timestamps
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
