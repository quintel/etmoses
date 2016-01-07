class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable

  has_many :testing_grounds
  has_many :topologies
  has_many :load_profiles
  has_many :profiles
  has_many :market_models

  validates_uniqueness_of :email

  def self.orphan
    User.find_by_email("orphan@quintel.com")
  end

  def name
    super || "somebody else"
  end
end
