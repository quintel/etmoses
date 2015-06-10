class RemoveTechnologiesRowFromTestingGrounds < ActiveRecord::Migration
  def change
    remove_column :testing_grounds, :technologies
  end
end
