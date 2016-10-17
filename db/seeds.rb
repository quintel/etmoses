# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Starting Technologies
# ---------------------

User.create!(
  email: 'guest@quintel.com',
  password: 'guest'
)

password = SecureRandom.hex[0..16]

user = User.create!(
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

MarketModelTemplate.create!(
  name: "Default Market Model",
  user: user,
  public: true,
  interactions: '[{"stakeholder_from":"customer","stakeholder_to":"supplier","foundation":"kwh_consumed","applied_stakeholder":"customer","tariff_type":"fixed","tariff":0.6}]'
)

TopologyTemplate.create!(
  name: "Default topology",
  user: user,
  public: true,
  graph: '{"name":"HV Network","stakeholder":"producer","children":[{"name":"HV-MV Trafo","capacity":16000,"technical_lifetime":30,"investment_cost":150000,"stakeholder":"system operator","children":[{"name":"MV-LV Trafo #1","capacity":2000,"technical_lifetime":30,"investment_cost":50000,"stakeholder":"system operator","children":[{"name":"Households 1","capacity":17.25,"units":33,"stakeholder":"customer"}]},{"name":"MV-LV Trafo #2","capacity":2000,"technical_lifetime":30,"investment_cost":50000,"stakeholder":"system operator","children":[{"name":"Households 2","capacity":17.25,"units":33,"stakeholder":"customer"}]},{"name":"MV-LV Trafo #3","capacity":2000,"technical_lifetime":30,"investment_cost":50000,"stakeholder":"system operator","children":[{"name":"Households 3","capacity":17.25,"units":33,"stakeholder":"cooperation"}]}]}]}'
)
