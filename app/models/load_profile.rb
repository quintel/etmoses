class LoadProfile < Profile
  belongs_to :load_profile_category
  belongs_to :user

  has_many :technology_profiles, dependent: :destroy
  has_many :load_curves, class: LoadCurve, dependent: :destroy

  validates :key, presence: true, uniqueness: true

  accepts_nested_attributes_for :technology_profiles,
    reject_if: :all_blank, allow_destroy: true

  def is_edsn?
    !!(key =~ /edsn/)
  end

  def self.in_name_order
    order('COALESCE(`name`, `key`), `name`, `key`')
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
