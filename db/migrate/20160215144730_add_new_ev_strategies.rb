class AddNewEvStrategies < ActiveRecord::Migration
  def up
    add_column :selected_strategies, :ev_storage,              :boolean, default: false, after: :battery_storage
    add_column :selected_strategies, :ev_excess_constrained,   :boolean, default: false, after: :battery_storage
    add_column :selected_strategies, :ev_capacity_constrained, :boolean, default: false, after: :battery_storage

    SelectedStrategy.reset_column_information

    # Buffering without storage
    SelectedStrategy.where(solar_storage: false, buffering_electric_car: true).
      update_all(
        ev_capacity_constrained: true,
        ev_excess_constrained: false,
        ev_storage: false
      )

    # Storage without buffering
    SelectedStrategy.where(solar_storage: true, buffering_electric_car: false).
      update_all(
        ev_capacity_constrained: true,
        ev_excess_constrained: true,
        ev_storage: true
      )

    # Buffering and storage
    SelectedStrategy.where(solar_storage: true, buffering_electric_car: true)
      .update_all(
        ev_capacity_constrained: true,
        ev_excess_constrained: false,
        ev_storage: true
      )

    remove_column :selected_strategies, :solar_storage
    remove_column :selected_strategies, :buffering_electric_car
  end

  def down
    add_column :selected_strategies, :solar_storage,          :boolean, default: false, after: :testing_ground_id
    add_column :selected_strategies, :buffering_electric_car, :boolean, default: false, after: :solar_power_to_gas

    SelectedStrategy.reset_column_information

    # Buffering without storage
    SelectedStrategy.where(
      ev_capacity_constrained: true,
      ev_excess_constrained: false,
      ev_storage: false
    ).update_all(
      solar_storage: false, buffering_electric_car: true
    )

    # Storage without buffering
    SelectedStrategy.where(
      ev_capacity_constrained: true,
      ev_excess_constrained: true,
      ev_storage: true
    ).update_all(
      solar_storage: true, buffering_electric_car: false
    )

    # Buffering and storage
    SelectedStrategy.where(
      ev_capacity_constrained: true,
      ev_excess_constrained: false,
      ev_storage: true
    ).update_all(
      solar_storage: true, buffering_electric_car: true
    )

    remove_column :selected_strategies, :ev_storage
    remove_column :selected_strategies, :ev_excess_constrained
    remove_column :selected_strategies, :ev_capacity_constrained
  end
end
