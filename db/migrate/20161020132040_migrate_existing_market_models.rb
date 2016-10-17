class MigrateExistingMarketModels < ActiveRecord::Migration
  def up
    TestingGround.where("`market_model_id` IS NOT NULL").each do |les|
      market_model_template = MarketModelTemplate.find_by_id(les.market_model_id)

      if market_model_template
        market_model = MarketModel.new
        market_model.market_model_template_id = market_model_template.id
        market_model.testing_ground_id = les.id
        market_model.interactions = market_model_template.interactions
        market_model.save
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
