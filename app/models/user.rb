class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable

  has_many :testing_grounds
  has_many :topologies
  has_many :load_profiles
  has_many :price_curves, class: PriceCurve
  has_many :market_models

  def self.orphan
    User.find_by_email("orphan@quintel.com")
  end
end
