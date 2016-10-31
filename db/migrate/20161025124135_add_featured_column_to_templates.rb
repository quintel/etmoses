class AddFeaturedColumnToTemplates < ActiveRecord::Migration
  def change
    add_column :topology_templates, :featured, :boolean, default: false, after: :id
    add_column :market_model_templates, :featured, :boolean, default: false, after: :id
  end
end
