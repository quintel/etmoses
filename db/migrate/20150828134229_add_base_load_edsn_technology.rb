class AddBaseLoadEdsnTechnology < ActiveRecord::Migration
  def change
    tech = Technology.create!({
      key: "base_load_edsn",
      name: "Household aggregated",
      behavior: "optional",
      visible: false
    })

    tech.component_behaviors.create!(curve_type: 'flex',   behavior: 'optional')
    tech.component_behaviors.create!(curve_type: 'inflex', behavior: 'generic')
  end
end
