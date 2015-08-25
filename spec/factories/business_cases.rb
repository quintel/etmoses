FactoryGirl.define do
  factory :business_case do
    testing_ground
    financials JSON.dump([
      {"aggregator"     =>[1, 0, 0, 0, 0, 0, 0]},
      {"cooperation"    =>[1, 0, 0, 0, 0, 0, 0]},
      {"customer"       =>[1, 0, 0, 0, 0, 0, 0]},
      {"government"     =>[1, 0, 0, 0, 0, 0, 0]},
      {"producer"       =>[1, 0, 0, 0, 0, 0, 0]},
      {"supplier"       =>[1, 0, 0, 0, 0, 0, 0]},
      {"system operator"=>[1, 0, 0, 0, 0, 0, 0]}
    ])
  end
end
