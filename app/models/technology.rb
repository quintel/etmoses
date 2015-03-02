class Technology
  include Virtus.model

  attribute :name,     String
  attribute :type,     String, default: 'generic'
  attribute :load,     Float
  attribute :profile,  String
  attribute :capacity, Float

  # Public: Returns if the technology has been defined in the data/technologies
  # directory.
  #
  # "Freeform" (no "type") technologies will return true.
  #
  # Returns true or false.
  def exists?
    type.blank? || Library::Technology.exists?(type)
  end

  # Public: Returns the matching "library" technology (as defined in
  # data/technologies). Techs with no "type" will return the "generic" library
  # tech.
  #
  # Returns a Library::Technology, or raises ActiveRecord::RecordNotFound if the
  # tech does not exist.
  def library
    Library::Technology.find(type.presence || 'generic')
  end

  # Public: Returns the load profile Curve, if the :profile attribute is set.
  #
  # Returns a Merit::Curve.
  def profile_curve
    profile && library.profile(profile)
  end
end # end
