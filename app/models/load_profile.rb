class LoadProfile < ActiveRecord::Base
  include Privacy

  belongs_to :load_profile_category
  belongs_to :user

  has_many :load_profile_components, dependent: :destroy
  has_many :technology_profiles, dependent: :destroy

  validates :key, presence: true, uniqueness: { case_sensitive: false }

  accepts_nested_attributes_for :technology_profiles,
    reject_if: :all_blank, allow_destroy: true

  accepts_nested_attributes_for :load_profile_components,
    reject_if: proc{ |l| l[:curve].blank? }, allow_destroy: true

  def self.in_name_order
    order("CASE WHEN `name` = '' THEN `key` ELSE `name` END")
  end

  def self.not_deprecated
    where("`key` NOT LIKE '%deprecated%'")
  end

  # Public: The human-readable name of the curve.
  def display_name
    name.presence || key
  end

  def deprecated?
    !!(key =~ /deprecated/)
  end

  def technologies
    Technology.where(key: technology_profiles.map(&:technology))
  end

  # Public: Returns all the curve components belonging to this profile within
  # a CurveCollection.
  def curves(range = nil)
    CurveCollection.new(load_profile_components, range)
  end

  def defaults
    { 'capacity' => default_capacity,
      'demand'   => default_demand,
      'volume'   => default_volume }
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
