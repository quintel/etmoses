class InstalledTechnology
  include Virtus.model

  attribute :name,     String
  attribute :type,     String, default: 'generic'
  attribute :load,     Float
  attribute :profile,  String
  attribute :capacity, Float
  attribute :demand,   Float

  # Public: Returns if the technology has been defined in the data/technologies
  # directory.
  #
  # "Freeform" (no "type") technologies will return true.
  #
  # Returns true or false.
  def exists?
    type.blank? || type == 'generic'.freeze || Technology.exists?(key: type)
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
  # Returns a Merit::Curve.
  def profile_curve
    load_profile = LoadProfile.find_by_key(profile)

    if capacity
      load_profile.merit_curve(:capacity_scaled) * capacity
    elsif demand
      load_profile.merit_curve(:demand_scaled) * demand
    else
      load_profile.merit_curve
    end
  end
end # end
