class Topology < ActiveRecord::Base
  include TopologyGraph

  belongs_to :topology_template
  belongs_to :testing_ground
end
