FactoryGirl.define do
  factory :technology do
    sequence(:key) { |n| "technology_#{ n }" }
    carrier        'electricity'
    importable_attributes ['electricity_output_capacity']
  end

  factory :importable_technology, class: Technology do
    sequence(:key) { |n| "technology_#{ n }" }
    carrier        'electricity'
    importable_attributes ['electricity_output_capacity']
    defaults       Hash.new(0)
  end
end
