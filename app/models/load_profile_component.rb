class LoadProfileComponent < ActiveRecord::Base
  include CurveComponent.module(styles: {
    demand_scaled:   { scale_by: :sum, processors: [:scaled_curve] },
    capacity_scaled: { scale_by: :max, processors: [:scaled_curve] }
  })

  CURVE_TYPES = { base_load: %w(flex inflex),
                  heat_pump: %w(use availability),
                  default:   %w(default) }

  belongs_to :load_profile
  validates_presence_of :curve_type

  def filename
    "#{ load_profile.display_name.gsub(/[^0-9A-Za-z.\-]/, '_') }.#{ curve_type }.csv"
  end
end
