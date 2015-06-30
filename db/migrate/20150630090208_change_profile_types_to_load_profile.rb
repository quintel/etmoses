class ChangeProfileTypesToLoadProfile < ActiveRecord::Migration
  def change
    Profile.update_all(type: "LoadProfile")
  end
end
