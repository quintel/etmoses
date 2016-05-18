class Technology < ActiveHash::Base
  include ActiveModel::Validations

  BEHAVIORS = %w(
    generic storage electric_vehicle siphon optional_buffer congestion_battery
    buffer deferrable conserving optional base_load base_load_buildings
  ).freeze

  validates :name,
    length: { maximum: 100 }

  validates :behavior, inclusion: { in: BEHAVIORS, allow_nil: true }

  validates :export_to,
    length: { maximum: 100 }

  def self.defaults
    {
      profile_required: true,
      visible: true,
      expandable: true,
      composite: false,
      default_demand: nil
    }
  end

  def self.importable
    all - where(importable_attributes: nil)
  end

  def self.visible
    where(visible: true)
  end

  def self.expandable
    where(expandable: true)
  end

  def self.for_concurrency
    where(
      expandable: true,
      visible: true,
      default_position_relative_to_buffer: nil
    )
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

  def self.base_loads
    [ by_key('base_load'), by_key('base_load_edsn') ]
  end

  def self.exists?(key)
    where(key: key).size > 0
  end

  def self.gquery
    all.select do |technology|
      technology.importable_gqueries.present?
    end
  end

  def name
    attributes[:name] || key.humanize.to_s
  end

  def profile_required?
    attributes[:profile_required]
  end

  def importable_attributes
    attributes[:importable_attributes] || []
  end

  def technologies
    attributes[:technologies] || []
  end
end
