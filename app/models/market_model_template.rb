class MarketModelTemplate < ActiveRecord::Base
  include Privacy
  include MarketModelInteractions

  FOUNDATIONS = Market::Builder::MEASURES.keys

  PRESENTABLES = %w(stakeholder_from
                    stakeholder_to
                    applied_stakeholder
                    foundation
                    tariff)

  DEFAULT_INTERACTIONS = [{ "stakeholder_from"    => "",
                            "stakeholder_to"      => "",
                            "tariff"              => "",
                            "tariff_type"         => "fixed",
                            "applied_stakeholder" => "",
                            "price"               => "" }]

  belongs_to :user

  has_many :market_models
  has_many :testing_grounds, -> { order(:name) }, through: :market_models

  validates :name, presence: true

  before_destroy :disassociate_market_models

  def self.featured
    where(featured: true)
  end

  def self.default
    find_by_name("Default Market Model")
  end

  private

  def disassociate_market_models
    market_models.update_all(market_model_template_id: nil)
  end
end
