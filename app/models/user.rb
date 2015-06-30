class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable

  has_many :testing_grounds
  has_many :topologies
  has_many :profiles
  has_many :market_models

  def activate!
    update_column(:activated, true)
  end
end
