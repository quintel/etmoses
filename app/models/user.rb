class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable

  has_many :testing_grounds
  has_many :topologies
  has_many :load_profiles

  def activate!
    update_column(:activated, true)
  end
end
