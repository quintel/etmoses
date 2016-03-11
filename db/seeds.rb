# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Starting Technologies
# ---------------------

User.create!(
  email: 'guest@quintel.com',
  password: 'guest'
)

password = SecureRandom.hex[0..16]

User.create!(
  email: "orphan@quintel.com",
  name: "ETMoses",
  password: password
)

[ "aggregator", "cooperation", "customer", "government", "producer", "supplier",
  "system operator"
].each do |name|
  Stakeholder.create!(name: name)
end

customer = Stakeholder.find_by_name("Customer")
8.times do |i|
  ['', 'a', 'b'].each do |suffix|
    Stakeholder.create!(name: "customer AC#{i + 1}#{suffix}", parent_id: customer.id)
  end
end
