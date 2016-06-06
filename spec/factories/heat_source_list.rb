FactoryGirl.define do
  factory :heat_source_list do
    testing_ground
    source_list JSON.dump([])
  end
end
