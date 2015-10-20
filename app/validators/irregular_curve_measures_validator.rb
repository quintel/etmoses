# Asserts that a market model may not have interactions using an irregular
# measure (those which don't return exactly 35,040 values) with a curve-based
# tariff.
class IrregularCurveMeasuresValidator < ActiveModel::Validator
  CURVE_TYPES = %w( curve merit ).freeze

  def validate(record)
    return if record.interactions.blank?

    curve_errors = Set.new

    record.interactions.each do |interaction|
      message = validate_interaction(interaction)
      curve_errors.add(message) if message
    end

    if curve_errors.any?
      curve_errors.each { |err| record.errors.add(:base, err) }
    end
  end

  private

  def validate_interaction(interaction)
    return if interaction['foundation'].blank?

    foundation = interaction['foundation'].downcase.to_sym
    measure    = Market::Builder::MEASURES[foundation]
    type       = interaction['tariff_type']

    return unless CURVE_TYPES.include?(type) && measure.try(:irregular?)

    "You may not use a #{ type } tariff with the " \
    "'#{ name(foundation) }' measure."
  end

  def name(foundation)
    I18n.t("tariff.measure.#{ foundation }").sub(/\A[A-Z]/) { |v| v.downcase }
  end
end
