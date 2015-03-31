FactoryGirl.define do
  factory :technology do
    sequence(:key) { |n| "technology_#{ n }" }
    name           { key.titleize }
    # key  "MyString"
    # name "MyString"
  end
end
