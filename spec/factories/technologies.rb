FactoryGirl.define do
  factory :technology do
    sequence(:key) { |n| "technology_#{ n }" }
    name           { key.titleize }
    carrier        'electricity'
    importable_attributes ['electricity_output_capacity']
  end

  factory :importable_technology, class: Technology do
    sequence(:key) { |n| "technology_#{ n }" }
    name           { key.titleize }
    carrier        'electricity'
    importable_attributes ['electricity_output_capacity']
  end
end
