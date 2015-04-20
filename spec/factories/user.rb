FactoryGirl.define do
  sequence :email do |n|
    "tester#{n}@quintel.com"
  end

  factory :user do
    email { generate(:email) }
    password_digest "test123"
  end
end
