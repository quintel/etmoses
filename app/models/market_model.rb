class MarketModel < ActiveRecord::Base
  include Privacy

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
  belongs_to :orginal, class: MarketModel

  serialize :interactions, JSON

  validates :name, presence: true
  validate :valid_interactions
  validates_with IrregularCurveMeasuresValidator

  private

  def valid_interactions
    return if interactions.blank?

    interactions.each do |interaction|
      PRESENTABLES.each do |attribute|
        if interaction[attribute].blank?
          errors.add(
            :interactions, :blank,
            attribute: I18n.t("market_model.table.headers.#{ attribute }").downcase
          )
        end
      end
    end
  end
end
