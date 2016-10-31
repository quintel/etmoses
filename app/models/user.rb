class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :recoverable

  has_many :testing_grounds
  has_many :topology_templates
  has_many :market_model_templates
  has_many :load_profiles
  has_many :profiles

  validates_uniqueness_of :email

  def self.orphan
    User.find_by_email("orphan@quintel.com")
  end

  def name
    super || "somebody else"
  end
end
