class PriceCurve < ActiveRecord::Base
  include Privacy
  include CurveComponent

  belongs_to :user

  has_attached_file :curve
  validates_attachment :curve, presence: true,
    content_type: { content_type: CurveComponent::VALID_CSV_TYPES },
    size: { less_than: 100.megabytes }
end
