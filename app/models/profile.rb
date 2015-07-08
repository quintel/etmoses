class Profile < ActiveRecord::Base
  include Privacy

  belongs_to :user

  has_many :profile_curves, class: ProfileCurve, dependent: :destroy

  validates :key, presence: true, uniqueness: true

  before_validation on: :create do
    if key.blank? && curve_file_name
      self.key = File.basename(
        curve_file_name, File.extname(curve_file_name)
      ).downcase
    end
  end

  accepts_nested_attributes_for :profile_curves

  def self.in_name_order
    order('COALESCE(`name`, `key`), `name`, `key`')
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
    begin
      where(key: key).first!
    rescue ActiveRecord::RecordNotFound
      raise TestingGround::DataError, I18n.t("testing_grounds.error.profile_not_found", profile: key)
    end
  end
end
