class CreateOrphanUser < ActiveRecord::Migration
  def change
    password = SecureRandom.hex[0..16]

    User.create!(email: "orphan@quintel.com", name: "ETMoses", password: password)
  end
end
