class AddKeyAndPublicToPriceCurves < ActiveRecord::Migration
  def change
    add_column :price_curves, :name, :string, after: :id
    add_column :price_curves, :key, :string, after: :name
    add_column :price_curves, :public, :boolean, after: :key, default: true
  end
end
