FactoryGirl.define do
  factory :heat_source_list do
    testing_ground
    asset_list JSON.dump([])
  end
end
