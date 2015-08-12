class InstalledTechnology
  include Virtus.model

  attribute :name,     String
  attribute :type,     String, default: 'generic'
  attribute :behavior, String
  attribute :profile,  Integer
  attribute :load,     Float
  attribute :capacity, Float
  attribute :demand,   Float
  attribute :volume,   Float
  attribute :units,    Integer, default: 1
  attribute :concurrency, String, default: 'max'

  EDITABLES = %i(name profile capacity volume demand units concurrency)

  # Public: Returns a template for a technology. For evaluation purposes
  def self.template
    Hash[ self.attribute_set.map do |attr|
      [attr.name.to_s, attr.default_value.call]
    end ]
  end

  def inspect
    "#<#{ self.class.name } #{ to_s }>"
  end

  def to_s
    "#{ name } (#{ type })"
  end

  # Public: Set the profile to be used to describe the technology load over
  # time.
  #
  # profile - A string describing the profile: either a load profile key, or a
  #           JSON-style array as a string.
  #
  # Returns the profile name.
  def profile=(profile)
    if profile && profile.is_a?(String) && profile.match(/\A\[.*\]\z/)
      super(JSON.parse(profile))
    else
      super
    end
  end

  # Public: Returns if the technology has been defined in the data/technologies
  # directory.
  #
  # "Freeform" (no "type") technologies will return true.
  #
  # Returns true or false.
  def exists?
    type.blank? || Technology.exists?(key: type)
  end

  # Public: Returns the associated technology (as defined in data/technologies).
  # Techs with no "type" will return the "generic" library tech.
  #
  # Returns a Technology, or raises ActiveRecord::RecordNotFound if the tech
  # does not exist.
  def technology
    type.present? ? Technology.by_key(type) : Technology.generic
  end

  # Public: Determines the network behavior of this technology with a particular
  # curve type. Base load technologies will behave differently depending on the
  # use of a flexible or inflexible curve.
  #
  # Returns a string.
  def behavior_with_curve(curve_type = nil)
    behavior = self.behavior.presence || technology.behavior

    return behavior if curve_type.nil? || curve_type == 'default'.freeze

    component_behavior = technology.component_behaviors.for_type(curve_type)
    component_behavior.try(:behavior) || behavior
  end

  # Public: Returns the load profile Curve, if the :profile attribute is set.
  #
  # Returns a Hash[{ <curve_type> => Network::Curve }]
  def profile_curve
    if profile.nil?
      { default: nil }
    elsif profile.is_a?(Array)
      curve = Network::Curve.new(profile)
      { default: curve * component_factor(curve) }
    elsif volume.blank? && (capacity || load)
      profile_curves(:capacity_scaled)
    elsif demand
      profile_curves(:demand_scaled)
    else
      profile_curves
    end
  end

  private

  # Internal: Retrieves the Network::Curve used by the technology, with
  # scaling applied for demand or capacity and a ratio.
  #
  # Returns a Hash[{ <curve_type> => Network::Curve }].
  def profile_curves(scaling = nil)
    Hash[profile_components.map do |component|
      curve = component.scaled_network_curve(scaling)
      [component.curve_type, curve * component_factor(curve) * ratio(component)]
    end]
  end

  def component_factor(curve)
    multiplier = volume || capacity || load

    if multiplier.nil?
      multiplier = (demand && demand * curve.frames_per_hour) || 1.0
    end

    multiplier * units
  end

  def ratio(component)
    component.network_curve.reduce(:+) / combined_components.reduce(:+)
  end

  def combined_components
    @combined_components ||= profile_components.map{|com| com.network_curve }.reduce(:+)
  end

  def profile_components
    @profile_components ||= LoadProfile.find_by_id(profile).load_profile_components
  end
end # end
