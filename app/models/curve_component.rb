module CurveComponent
  extend ActiveSupport::Concern

  included do
    validate :validate_curve_length
  end

  VALID_CSV_TYPES = ["data:text/csv", "text/csv", "text/plain",
                     "application/octet-stream", "application/vnd.ms-excel"]

  def as_json(*)
    super.merge('values' => network_curve.to_a)
  end

  # Public: Returns the Network::Curve which containing each of the load profile
  # values.
  def network_curve(scaling = :original)
    cache_key = "profile.#{ id }.#{ curve_updated_at.to_s(:db) }.#{ scaling }"

    Rails.cache.fetch(cache_key) do
      Network::Curve.load_file(curve.path(scaling))
    end
  end

  def scaled_network_curve(scaling)
    Network::Curve.new(
      case scaling
        when :capacity_scaled then Paperclip::ScaledCurve.scale(network_curve, :max)
        when :demand_scaled   then Paperclip::ScaledCurve.scale(network_curve, :sum)
        else network_curve
      end.to_a
    )
  end

  private

  def validate_curve_length
    return unless curve && curve.queued_for_write[:original]

    length = Network::Curve.load_file(
      curve.queued_for_write[:original].path
    ).length

    # 8760 is permitted in tests, but not *currently* officially supported in
    # the front-end.
    unless length == 8760 || length == 35040
      errors.add(
        :curve,
        "must have 35,040 values, but the uploaded file has #{ length }"
      )
    end
  end
end
