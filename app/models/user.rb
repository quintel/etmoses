class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable

  has_many :testing_grounds
  has_many :topologies
  has_many :load_profiles
  has_many :price_curves, class: PriceCurve
  has_many :market_models

  def activate!
    update_column(:activated, true)
  end

  def active_for_authentication?
    super && activated?
  end

  def inactive_message
    if !activated?
      :not_activated
    else
      super # Use whatever other message
    end
  end
end
