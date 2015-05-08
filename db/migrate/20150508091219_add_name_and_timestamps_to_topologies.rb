class AddNameAndTimestampsToTopologies < ActiveRecord::Migration
  def change
    add_column :topologies, :name, :string, after: :id
    add_column :topologies, :created_at, :datetime
    add_column :topologies, :updated_at, :datetime

    Topology.all.each do |t|
      t.created_at = DateTime.now
      t.save!
    end
  end
end
