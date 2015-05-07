class AddUserIdToTestingGrounds < ActiveRecord::Migration
  def change
    add_column :testing_grounds, :user_id, :integer, after: :technology_profile

    user = User.find_by_email("chael.kruip@quintel.com")
    TestingGround.update_all(user_id: user.id)
  end
end
