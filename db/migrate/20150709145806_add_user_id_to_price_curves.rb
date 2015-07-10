class AddUserIdToPriceCurves < ActiveRecord::Migration
  def change
    add_column :price_curves, :user_id, :integer, after: :id
  end
end
