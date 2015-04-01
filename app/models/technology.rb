class Technology < ActiveRecord::Base
  # Defines attributes which may be read from ETEngine and imported into the
  # testing ground. Each key is an attribute provided by ETE, and the value is
  # the local attribute to which it maps.
  IMPORT_ATTRIBUTES = {
    demand:                      :demand,
    electricity_output_capacity: :capacity,
    input_capacity:              :capacity
  }.freeze

  validates :key,
    presence: true,
    length: { maximum: 100 },
    uniqueness: true,
    exclusion: { in: %w( generic ) }

  validates :name,
    length: { maximum: 100 }

  validates :import_from,
    length: { maximum: 50 },
    inclusion: { in: IMPORT_ATTRIBUTES.keys.map(&:to_s), allow_blank: true }

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
