class MigrateExistingStakeholders < ActiveRecord::Migration
  def change
    [ "aggregator", "cooperation", "customer", "government", "producer", "supplier",
      "system operator" ].each do |name|
      Stakeholder.create!(name: name)
    end

    customer = Stakeholder.find_by_name("Customer")
    8.times do |i|
      ['', 'a', 'b'].each do |suffix|
        Stakeholder.create!(name: "customer AC#{i + 1}#{suffix}", parent_id: customer.id)
      end
    end
  end
end
