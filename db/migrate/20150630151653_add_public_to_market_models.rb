class AddPublicToMarketModels < ActiveRecord::Migration
  def change
    add_column :market_models, :public, :boolean, default: false, after: :name
  end
end
