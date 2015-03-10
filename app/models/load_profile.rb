class LoadProfile < ActiveRecord::Base
  has_attached_file :curve

  validates_attachment :curve, presence: true,
    content_type: { content_type: 'text/csv' },
    size: { less_than: 100.megabytes }

  validates :key, presence: true, uniqueness: true

  before_validation on: :create do
    if key.blank? && curve_file_name
      self.key = File.basename(curve_file_name, File.extname(curve_file_name))
    end
  end

  # Public: Returns the Merit::Curve which containing each of the load profile
  # values.
  def merit_curve
    Rails.cache.fetch("profile.#{ id }.#{ curve_updated_at.to_s(:db) }") do
      Merit::Curve.load_file(curve.path)
    end
  end

  # Public: The human-readable name of the curve.
  def display_name
    name.presence || key
  end

  # Public: Given the unique key representing a load profile, returns the
  # profile or raises ActiveRecord::RecordNotFound.
  def self.find_by_key(key)
    by_key(key).first!
  end

  # Public: Given the unique key representing a load profile, returns the
  # profile or raises ActiveRecord::RecordNotFound.
  def self.by_key(key)
    where(key: key)
  end
end
