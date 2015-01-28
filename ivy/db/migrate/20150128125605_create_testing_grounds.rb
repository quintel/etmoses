class CreateTestingGrounds < ActiveRecord::Migration
  def up
    create_table :testing_grounds do |t|
      t.text :technologies, limit: 16_777_215, null: false
      t.belongs_to :topology
      t.timestamps
    end

    TestingGround.reset_column_information

    Topology.find_each do |topology|
      TestingGround.create!(
        technologies: topology.technologies,
        topology_id:  topology.id,
        created_at:   topology.created_at,
        updated_at:   topology.updated_at
      )
    end

    remove_column :topologies, :technologies
    remove_column :topologies, :created_at
    remove_column :topologies, :updated_at
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
