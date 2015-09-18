module CurveComponent
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
end
