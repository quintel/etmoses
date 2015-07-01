class LoadProfile < Profile
  belongs_to :load_profile_category

  has_many :technology_profiles, dependent: :destroy

  accepts_nested_attributes_for :technology_profiles,
    reject_if: :all_blank, allow_destroy: true
end
