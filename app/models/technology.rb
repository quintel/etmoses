class Technology < ActiveRecord::Base
  validates :key,
    presence: true,
    length: { maximum: 100 },
    uniqueness: true,
    exclusion: { in: %w( generic ) }

  validates :name,
    length: { maximum: 100 }

  validates :import_from,
    length: { maximum: 50 },
    inclusion: {
      in: Import::TechnologyBuilder::ATTRIBUTES.keys,
      allow_blank: true }

  validates :export_to,
    length: { maximum: 100 }

  # Public: Returns a "generic" technology, which represents an installed
  # technology with no explicit type.
  def self.generic
    @@generic ||= Technology.new(key: 'generic'.freeze)
  end

  # Public: Retrieves the record with the matching +key+ or raises
  # ActiveRecord::RecordNotFound if no such record exists.
  def self.by_key(key)
    key == 'generic'.freeze ? generic : where(key: key).first!
  end

  # Public: A nice, readable name for the technology.
  def name
    super || key.to_s.humanize
  end
end
