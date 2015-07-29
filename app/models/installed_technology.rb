class InstalledTechnology
  include Virtus.model

  attribute :name,     String
  attribute :type,     String, default: 'generic'
  attribute :behavior, String
  attribute :profile,  String
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

  # Public: Returns the load profile Curve, if the :profile attribute is set.
  #
  # Returns a Network::Curve.
  def profile_curve
    if profile.is_a?(Array)
      { default: Network::Curve.new(profile) }
    elsif volume.blank? && (capacity || load)
      profile_curves(:capacity_scaled)
    elsif demand
      profile_curves(:demand_scaled)
    else
      profile_curves
    end
  end

  private

  # Internal: Retrieves the Network::Curve used by the technology, without any
  # scaling applied for demand or capacity.
  #
  # Returns a Network::Curve.
  def profile_curves(scaling = nil)
    multiplier = volume || capacity || load

    if multiplier.nil?
      multiplier = (demand && demand * curve.frames_per_hour) || 1.0
    end

    multiplier = multiplier * units

    Hash[profile_components.map do |profile_component|
      [ profile_component.curve_type,
        scaled_curve(profile_component.network_curve, scaling) * multiplier ]
    end]
  end

  def profile_components
    @profile_components ||= LoadProfile.by_key(profile).load_profile_components
  end

  def scaled_curve(curve, scaling = nil)
    Network::Curve.new(
      case scaling
        when :capacity_scaled then Paperclip::ScaledCurve.scale(curve, :max)
        when :demand_scaled   then Paperclip::ScaledCurve.scale(curve, :sum)
        else curve
      end.to_a
    )
  end
end # end
