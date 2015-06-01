class LoadProfile < ActiveRecord::Base
  include Privacy

  has_many :technology_profiles, dependent: :destroy

  belongs_to :load_profile_category
  belongs_to :user

  has_attached_file :curve, styles: {
    demand_scaled:   { scale_by: :sum, processors: [:scaled_curve] },
    capacity_scaled: { scale_by: :max, processors: [:scaled_curve]}
  }

  validates_attachment :curve, presence: true,
    content_type: { content_type: /text\/(csv|plain)/ },
    size: { less_than: 100.megabytes }

  validates :key, presence: true, uniqueness: true

  before_validation on: :create do
    if key.blank? && curve_file_name
      self.key = File.basename(
        curve_file_name, File.extname(curve_file_name)
      ).downcase
    end
  end

  accepts_nested_attributes_for :technology_profiles,
    reject_if: :all_blank, allow_destroy: true

  def self.overview(user)
    visible_to(user).order(:key)
  end

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

  # Public: The human-readable name of the curve.
  def display_name
    name.presence || key
  end

  # Public: Given the unique key representing a load profile, returns the
  # profile or raises ActiveRecord::RecordNotFound.
  def self.by_key(key)
    where(key: key).first!
  end
end
