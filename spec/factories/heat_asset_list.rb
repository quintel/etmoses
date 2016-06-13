FactoryGirl.define do
  factory :heat_asset_list do
    testing_ground
    asset_list JSON.dump([])
  end
end

