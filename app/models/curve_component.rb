module CurveComponent
  VALID_CSV_TYPES = ["text/csv", "text/plain", "application/octet-stream"]

  def as_json(*)
    super.merge('values' => merit_curve.to_a)
  end

  # Public: Returns the Merit::Curve which containing each of the load profile
  # values.
  def merit_curve(scaling = :original)
    cache_key = "profile.#{ id }.#{ curve_updated_at.to_s(:db) }.#{ scaling }"

    Rails.cache.fetch(cache_key) do
      csv_file = CSV.read(curve.path(scaling))

      Merit::Curve.new(csv_file.flatten.map(&:to_f))
    end
  end
end
