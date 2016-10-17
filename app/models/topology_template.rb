class TopologyTemplate < ActiveRecord::Base
  DEFAULT_GRAPH = Rails.root.join('db/default_topology_template.yml').read

  include TopologyGraph
  include Privacy

  belongs_to :user

  has_many :topologies
  has_many :testing_grounds, -> { order(:name) }, through: :topologies

  validates_presence_of :name

  validate :validate_graph_yaml

  before_destroy :disassociate_topologies

  def self.featured
    where(featured: true)
  end

  def self.in_name_order
    order(:name)
  end

  def self.named
    where("`name` IS NOT NULL").in_name_order
  end

  def self.default
    find_by_name("Default topology")
  end

  def filename
    name.gsub(/[^A-Za-z0-9\-\.]/, '-').gsub(/\-+/, '-')
  end

  private

  def disassociate_topologies
    topologies.update_all(topology_template_id: nil)
  end

  def validate_graph_yaml
    begin
      self.graph = if graph.is_a?(String)
        YAML.load(graph.gsub(/\t/, ' ' * 4)) || {}
      else
        graph
      end
    rescue Psych::SyntaxError => e
      errors.add(:graph, e.message)
    end
  end
end
