class Topology < ActiveRecord::Base
  serialize :graph,        JSON
  serialize :technologies, JSON

  DEFAULT_GRAPH        = Rails.root.join('db/default_topology.yml').read
  DEFAULT_TECHNOLOGIES = Rails.root.join('db/default_technologies.yml').read
end
