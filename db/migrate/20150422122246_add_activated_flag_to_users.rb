class AddActivatedFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :activated, :boolean, default: false, after: :password_digest

    User.update_all({activated: true})
  end
end
