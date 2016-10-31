module MarketModelInteractions
  extend ActiveSupport::Concern

  included do
    serialize :interactions, JSON

    validate :valid_interactions
    validates_with IrregularCurveMeasuresValidator
  end

  def interactions=(interactions)
    if interactions.is_a?(String)
      super(JSON.parse(interactions))
    else
      super(interactions)
    end
  end

  private

  def valid_interactions
    return if interactions.blank?

    interactions.each do |interaction|
      MarketModelTemplate::PRESENTABLES.each do |attribute|
        if interaction[attribute].blank?
          # Tariff may be blank when using a merit curve for pricing.
          next if attribute == 'tariff' && interaction['tariff_type'] == 'merit'

          errors.add(
            :interactions, :blank,
            attribute: I18n.t("market_model_template.table.headers.#{ attribute }").downcase
          )
        end
      end
    end
  end
end
