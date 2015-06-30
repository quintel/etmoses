module CurveComponent
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
end
