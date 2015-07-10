include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :load_profile do
    sequence(:key){|n| "key_#{n}"}
  end

  factory :load_profile_with_curve, class: LoadProfile do
    sequence(:key) {|n| "key_#{n}_with_curve"}

    load_profile_components { build_list :load_profile_component, 1 }
  end
end
