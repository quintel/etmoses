FactoryGirl.define do
  factory :technology_component_behavior do
    technology
    curve_type 'flex'
    behavior 'deferred'
  end
end
