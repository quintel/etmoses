class TechnologyList
  include Enumerable
  extend  Forwardable

  def_delegators :@list, :each, :keys, :to_h, :[]=, :delete, :empty?, :blank?

  # Public: Given a hash containing node keys, and a list of technologies
  # attached to the node, converts this into a TechnologyList where each tech
  # becomes a Technology instance.
  #
  # Returns a TechnologyList.
  def self.load(data)
    data.blank? ? new({}) : from_hash(JSON.parse(data))
  end

  # Public: Given a hash containing node keys, and a list of technologies
  # attached to the node, converts this into a TechnologyList where each tech
  # becomes a Technology instance.
  #
  # Returns a TechnologyList.
  def self.from_hash(data)
    new(Hash[data.map do |node_key, technologies|
      [node_key, technologies.map(&Technology.method(:new))]
    end])
  end

  # Public: Given a TechnologyList, converts it back to the raw hash form for
  # storage in a database.
  #
  # Returns a hash.
  def self.dump(list)
    JSON.dump(Hash[list.to_h.map { |key, techs| [key, techs.map(&:to_h)] }])
  end

  # Returns the raw hash containing each technology keyed on it's owner node.
  attr_reader :list

  # Public: Creates a new TechnologyList. Contains the technologies defined
  # within a testing ground.
  def initialize(list = {})
    @list = list
  end

  # Public: Iterates through all technologies in the testing ground.
  def each_tech(&block)
    @list.values.flatten.each(&block)
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
end # TechnologyList
