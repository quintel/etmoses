class LoadProfile < ActiveRecord::Base
  include Privacy

  belongs_to :load_profile_category
  belongs_to :user

  has_many :load_profile_components, dependent: :destroy
  has_many :technology_profiles, dependent: :destroy

  validates :key, presence: true, uniqueness: true

  accepts_nested_attributes_for :technology_profiles,
    reject_if: :all_blank, allow_destroy: true

  accepts_nested_attributes_for :load_profile_components,
    reject_if: proc{ |l| l[:curve].blank? }, allow_destroy: true

  def self.in_name_order
    order('COALESCE(`name`, `key`), `name`, `key`')
  end

  def self.not_deprecated
    where("`key` NOT LIKE '%deprecated%'")
  end

  # Public: The human-readable name of the curve.
  def display_name
    name.presence || key
  end

  def is_edsn?
    !!(key =~ /edsn/)
  end

  def deprecated?
    !!(key =~ /deprecated/)
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
