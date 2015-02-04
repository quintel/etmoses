class Technology
  include Virtus.model

  # Path to the load profiles.
  PROFILE_DIR = Rails.root.join('data/curves')

  attribute :key,      String
  attribute :profiles, Array[String]

  # Public: A hash where each key is the name of a load profile, and each value
  # the Merit::Curve containing the curve data.
  #
  # Returns a hash.
  def profiles
    @loaded_profiles ||= super.each_with_object({}) do |key, data|
      data[key] = Merit::Curve.load_file(PROFILE_DIR.join("#{ key }.csv"))
    end
  end

  class << self
    # Public: An array containing all loaded technologies.
    def all
      loaded_files.values
    end

    # Public: Given a +key+, finds the technology with a matching key. Raises an
    # ActiveRecord::RecordNotFound if the technology does not exist.
    #
    # Returns a Technology.
    def find(key)
      loaded_files[key] || fail(ActiveRecord::RecordNotFound)
    end

    #######
    private
    #######

    # Internal: Loads all technologies from disk, returning a hash where each
    # key is the YAML file name (sans ".yml") and each value is the loaded
    # technology instance.
    #
    # Returns a hash.
    def loaded_files
      @loaded ||= begin
        files = Pathname.glob(Rails.root.join('data/technologies/*.yml'))

        files.each_with_object({}) do |file, data|
          key        = file.basename.to_s[0...-4]
          attributes = YAML.load_file(file)

          data[file.basename.to_s[0...-4]] =
            new(YAML.load_file(file).merge(key: key))
        end
      end
    end
  end # class << self
end # end
