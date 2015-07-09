class CreatePriceCurves < ActiveRecord::Migration
  def change
    create_table :price_curves do |t|
      t.string :curve_file_name
      t.string :curve_content_type
      t.integer :curve_file_size
      t.datetime :curve_updated_at
      t.timestamps
    end
  end
end
