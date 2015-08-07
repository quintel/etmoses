class TechnologyComponentBehavior < ActiveRecord::Base
  belongs_to :technology

  validates :curve_type, inclusion: { in: %w( flex inflex ) }, uniqueness: { scope: :technology_id }
  validates :behavior,   inclusion: { in: Technology::BEHAVIORS }

  def self.for_type(type)
    where(curve_type: type).first
  end
end
