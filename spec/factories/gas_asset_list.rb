FactoryGirl.define do
  factory :gas_asset_list do
    testing_ground
    asset_list JSON.dump([])
  end
end

