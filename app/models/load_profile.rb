class LoadProfile < Profile
  belongs_to :load_profile_category

  has_many :technology_profiles, dependent: :destroy

  has_attached_file :curve, styles: {
    demand_scaled:   { scale_by: :sum, processors: [:scaled_curve] },
    capacity_scaled: { scale_by: :max, processors: [:scaled_curve] }
  }

  accepts_nested_attributes_for :technology_profiles,
    reject_if: :all_blank, allow_destroy: true

  def is_edsn?
    !!(key =~ /edsn/)
  end
end
