module Library
  class Technology
    include Virtus.model

    attribute :key,      String
    attribute :profiles, Array[String]

    # Public: Given the name of a profile, returns that profile as Merit::Curve.
    # If the profile may not be used by this technology, a
    def profile(name)
      if permitted_profile?(name)
        Rails.cache.fetch("static.tech_profiles.#{ name }") do
          Merit::Curve.load_file(profile_map[name])
        end
      end
    end

    # Public: Returns a list of profiles which may be used with this technology.
    def profile_map
      Rails.cache.fetch("static.permitted_profiles.#{ key }") do
        expanded = profiles.map do |pattern|
          Pathname.glob(Ivy.data_dir.join("curves/#{ pattern }.csv"))
        end.flatten.compact.uniq

        Hash[expanded.map { |file| [file.basename.to_s[0..-5], file] }]
      end
    end

    # Public: Returns if the given load profile key may be used with this
    # technology.
    def permitted_profile?(key)
      profile_map.key?(key)
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

      # Public: Returns whether a technology matching the given key exists.
      def exists?(key)
        loaded_files.key?(key)
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
        Rails.cache.fetch('static.technologies'.freeze) do
          files = Pathname.glob(Ivy.data_dir.join('technologies/*.yml'))

          files.each_with_object({}) do |file, data|
            key        = file.basename.to_s[0...-4]
            attributes = YAML.load_file(file)

            data[file.basename.to_s[0...-4]] =
              new(YAML.load_file(file).merge(key: key))
          end
        end
      end
    end # class << self
  end # Technology
end # Library
