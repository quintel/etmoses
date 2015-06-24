class Technology < ActiveRecord::Base
  has_many :importable_attributes, dependent: :delete_all
  has_many :technology_profiles, foreign_key: "technology", primary_key: "key"
  has_many :load_profiles, through: :technology_profiles

  validates :key,
    presence: true,
    length: { maximum: 100 },
    uniqueness: true

  validates :name,
    length: { maximum: 100 }

  validates :behavior,
    inclusion: {
      in: %w( storage electric_vehicle siphon buffer
              preemptive deferrable conserving ),
      allow_nil: true }

  validates :export_to,
    length: { maximum: 100 }


  def self.with_load_profiles
    joins(:load_profiles).uniq + where(key: 'generic')
  end

  # Public: Returns a "generic" technology, which represents an installed
  # technology with no explicit type.
  def self.generic
    @@generic ||= Technology.find_by_key('generic')
  end

  # Public: Retrieves the record with the matching +key+ or raises
  # ActiveRecord::RecordNotFound if no such record exists.
  def self.by_key(key)
    key == 'generic' ? generic : where(key: key).first!
  end

  # Public: A nice, readable name for the technology.
  def name
    super || key.to_s.humanize
  end
end
