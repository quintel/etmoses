class MoveTestingGroundsTopologies < ActiveRecord::Migration
  def change
    add_reference :topologies, :testing_ground, index: true, unique: true, after: :graph
  end
end
