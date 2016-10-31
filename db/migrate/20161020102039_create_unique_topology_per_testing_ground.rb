class CreateUniqueTopologyPerTestingGround < ActiveRecord::Migration
  def change
    Topology.reset_column_information

    TestingGround.all.each do |testing_ground|
      topology = Topology.find_by_id(testing_ground.topology_id)

      if topology
        if topology.testing_ground_id.present?
          dup_topology = topology.dup
          dup_topology.save
          dup_topology.update_column(:testing_ground_id, testing_ground.id)
        else
          topology.update_column(:testing_ground_id, testing_ground.id)
        end
      end
    end
  end
end
