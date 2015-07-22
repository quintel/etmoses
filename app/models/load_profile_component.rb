class LoadProfileComponent < ActiveRecord::Base
  include CurveComponent

  CURVE_TYPES = %w(flex inflex)

  belongs_to :load_profile

  has_attached_file :curve, styles: {
    demand_scaled:   { scale_by: :sum, processors: [:scaled_curve] },
    capacity_scaled: { scale_by: :max, processors: [:scaled_curve]}
  }

  validates_presence_of :curve_type
  validates_attachment :curve, presence: true,
    content_type: { content_type: CurveComponent::VALID_CSV_TYPES },
    size: { less_than: 100.megabytes }
end
