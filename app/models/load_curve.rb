class LoadCurve < ActiveRecord::Base
  belongs_to :load_profile

  has_attached_file :curve, styles: {
    demand_scaled:   { scale_by: :sum, processors: [:scaled_curve] },
    capacity_scaled: { scale_by: :max, processors: [:scaled_curve]}
  }

  validates_presence_of :curve_type
  validates_attachment :curve, presence: true,
    content_type: { content_type: /text\/(csv|plain)/ },
    size: { less_than: 100.megabytes }

  # Public: Returns a hash containing the values to be serialised as JSON.
  # Includes the raw curve values.
  def as_json(*)
    super.merge('values' => merit_curve.to_a)
  end

  # Public: Returns the Merit::Curve which containing each of the load profile
  # values.
  def merit_curve(scaling = :original)
    cache_key = "profile.#{ id }.#{ curve_updated_at.to_s(:db) }.#{ scaling }"

    Rails.cache.fetch(cache_key) do
      Merit::Curve.load_file(curve.path(scaling))
    end
  end

end
