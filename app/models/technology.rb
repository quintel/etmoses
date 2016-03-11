class Technology < ActiveHash::Base
  include ActiveModel::Validations

  FILE_ROOT = "#{ Rails.root }/config/technologies"

  BEHAVIORS = %w(
    generic storage electric_vehicle siphon optional_buffer congestion_battery
    buffer deferrable conserving optional base_load base_load_buildings
  ).freeze

  validates :name,
    length: { maximum: 100 }

  validates :behavior, inclusion: { in: BEHAVIORS, allow_nil: true }

  validates :export_to,
    length: { maximum: 100 }

  def self.importable
    all - where(importable_attributes: [])
  end

  def self.visible
    where(visible: true)
  end

  def self.expandable
    where(expandable: true)
  end

  def self.for_concurrency
    where(expandable: true, visible: true)
  end

  # Public: Returns a "generic" technology, which represents an installed
  # technology with no explicit type.
  def self.generic
    @@generic ||= Technology.find_by_key('generic')
  end

  # Public: Retrieves the record with the matching +key+ or raises
  # ActiveRecord::RecordNotFound if no such record exists.
  def self.by_key(key)
    key == 'generic' ? generic : where(key: key).first
  end

  def self.exists?(key)
    where(key: key).size > 0
  end

  def name
    attributes[:name] || key.humanize.to_s
  end

  def profile_required?
    true || profile_required
  end

  def technologies
    attributes[:technologies] || []
  end
end
