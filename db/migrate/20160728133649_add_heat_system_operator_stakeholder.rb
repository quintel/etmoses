class AddHeatSystemOperatorStakeholder < ActiveRecord::Migration
  def up
    Stakeholder.create(name: 'heat system operator')
  end

  def down
    Stakeholder.where(name: 'heat system opearator').delete_all
  end
end
