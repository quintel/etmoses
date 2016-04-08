class AddRequiresProfileToTechnologies < ActiveRecord::Migration
  def change
    add_column :technologies, :profile_required, :boolean, default: true, after: :visible

    tech_keys = %w(congestion_battery
                   households_flexibility_p2p_electricity
                   energy_flexibility_p2g_electricity)

    Technology.where(key: tech_keys).update_all(profile_required: false)
  end
end
