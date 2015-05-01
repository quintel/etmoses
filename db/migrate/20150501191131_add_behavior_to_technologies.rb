class AddBehaviorToTechnologies < ActiveRecord::Migration
  def up
    add_column :technologies, :behavior, :string, limit: 50

    Technology.by_key('transport_car_using_electricity')
      .update!(behavior: 'electric_vehicle')
  end

  def down
    remove_column :technologies, :behavior
  end
end
