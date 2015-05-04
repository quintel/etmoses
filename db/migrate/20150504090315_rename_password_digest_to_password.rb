class RenamePasswordDigestToPassword < ActiveRecord::Migration
  def change
    rename_column :users, :password_digest, :encrypted_password
    change_column :users, :encrypted_password, :string, default: ""
  end
end
