class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable

  def activate!
    update_column(:activated, true)
  end
end
