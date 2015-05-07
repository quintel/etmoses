class AddTechnologyProfilesToTestingGrounds < ActiveRecord::Migration
  def change
    add_column :testing_grounds, :technology_profile, :text, after: :technologies
  end
end
