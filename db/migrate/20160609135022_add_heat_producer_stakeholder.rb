class AddHeatProducerStakeholder < ActiveRecord::Migration
  def up
    Stakeholder.create(name: 'heat producer')
  end

  def down
    Stakeholder.where(name: 'heat producer').delete_all
  end
end
