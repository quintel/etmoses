class AllTestingGroundsAreFromChael < ActiveRecord::Migration
  def change
    TestingGround.update_all(user_id: User.find_by_email("chael.kruip@quintel.com").id)
  end
end
