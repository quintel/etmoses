class AddOriginalIdToTopologies < ActiveRecord::Migration
  def change
    add_column :topologies, :original_id, :integer, after: :user_id
    add_column :market_models, :original_id, :integer, after: :user_id
  end
end
