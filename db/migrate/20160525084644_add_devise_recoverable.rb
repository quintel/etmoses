class AddDeviseRecoverable < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.datetime :reset_password_sent_at, after: :encrypted_password
      t.string   :reset_password_token,   after: :encrypted_password

      t.index    :reset_password_token, unique: true
    end
  end
end
