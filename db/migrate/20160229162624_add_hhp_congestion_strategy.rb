class AddHhpCongestionStrategy < ActiveRecord::Migration
  def change
    add_column :selected_strategies, :hhp_switch_to_gas,
      :boolean, default: false, after: :hp_capacity_constrained
  end
end
