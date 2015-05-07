class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable

  has_many :testing_grounds

  def activate!
    update_column(:activated, true)
  end
end
