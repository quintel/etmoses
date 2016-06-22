class TechnologyList
  include Enumerable
  extend Forwardable

  def_delegators :@list, :each, :keys, :to_h, :[]=, :delete, :empty?, :blank?

  # Public: Given a hash containing node keys, and a list of technologies
  # attached to the node, converts this into a TechnologyList where each tech
  # becomes an InstalledTechnology instance.
  #
  # Returns a TechnologyList.
  def self.load(data)
    data.blank? ? new({}) : from_hash(JSON.parse(data))
  end

  def self.initiate_technology(tech, profiles)
    profile_id = tech['profile']
    profile_key = tech['profile_key']

    attributes = if profile_key && profile_id.blank?
      { 'profile' => profiles.key(profile_key) }
    elsif profile_key.blank? && profile_id.try(:to_i)
      { 'profile_key' => profiles[profile_id.to_i] }
    end

    InstalledTechnology.new(tech.update(attributes || {}))
  end

  # Public: Given a hash containing node keys, and a list of technologies
  # attached to the node, converts this into a TechnologyList where each tech
  # becomes an InstalledTechnology instance.
  #
  # Returns a TechnologyList.
  def self.from_hash(data)
    profiles = load_profiles(data)

    new(Hash[data.map do |node_key, technologies|
      [node_key, technologies.map do |technology|
        initiate_technology(technology, profiles)
      end]
    end])
  end

  def self.fetch_key(technology)
    technology['profile'] || technology['profile_key']
  end

  def self.load_profiles(data)
    profile_ids = data.values.flatten.map(&method(:fetch_key)).compact.uniq

    Hash[
      LoadProfile.where('`id` IN (:profile_ids) OR `key` IN (:profile_ids)',
                        profile_ids: profile_ids).pluck(:id, :key)
    ]
  end

  # Public: Given a TechnologyList, converts it back to the raw hash form for
  # storage in a database.
  #
  # Returns a hash.
  def self.dump(list)
    JSON.dump(Hash[list.to_h.map { |key, techs| [key, techs.map(&:to_h)] }])
  end

  # Public: Given a CSV file as a string, creates a TechnologyList.
  #
  # Parses the contents of the CSV into a new TechnologyList. The file is
  # expected to contain a header row naming each column, with a mandatory
  # "connection" column describing to which node the technology is attached.
  #
  # Returns a TechnologyList.
  def self.from_csv(csv)
    parsed = CSV.parse(csv, headers: true)

    data = parsed.each_with_object({}) do |row, data|
      data[row['connection']] ||= []
      data[row['connection']].push(
        row.to_h.except('connection').merge(
          associates: parse_csv_value_array(row['associates']),
          includes:   parse_csv_value_array(row['includes'])
        )
      )
    end

    TechnologyList.from_hash(data)
  end

  # Internal: Parses a attribute imported from a CSV file which may be an
  # array containing technology keys.
  #
  # TODO Loading the CSV should be refactored into a separate class.
  #
  # Returns an Array.
  def self.parse_csv_value_array(value)
    (value && value.first == '['.freeze) ? JSON.parse(value) : []
  end

  private_class_method :parse_csv_value_array

  # Returns the raw hash containing each technology keyed on it's owner node.
  attr_reader :list

  # Public: Creates a new TechnologyList. Contains the technologies defined
  # within a testing ground.
  def initialize(list = {})
    @list = list
  end

  # Public: Iterates through all technologies in the testing ground.
  def each_tech(&block)
    block_given? ? @list.values.flatten.each(&block) : enum_for(:each_tech)
  end

  # Public: Given a node key, returns the attached technologies in an array.
  def [](key)
    @list[key] || []
  end

  # Public: Converts the list to a JSON representation.
  def as_json(*)
    each_with_object({}) do |(node, techs), data|
      data[node] = techs.map(&:to_h)
    end
  end

  def profiles
    @profiles ||= begin
      profile_ids = @list.values.flatten.map(&:profile).reject do |profile|
        profile.is_a?(Array) || profile.is_a?(Hash)
      end

      Hash[LoadProfile.where(id: profile_ids.compact.uniq).map do |load_profile|
        [load_profile.id, load_profile]
      end]
    end
  end

  # Public: Converts the technology list to a CSV file.
  def to_csv
    attributes = InstalledTechnology::PRESENTABLES
    options    = { headers: [:connection, *attributes], write_headers: true }

    CSV.generate(options) do |csv|
      each do |connection, technologies|
        technologies.each do |technology|
          csv << [connection, *attributes.map do |attribute|
            technology.send(attribute)
          end]
        end
      end
    end
  end
end # TechnologyList
