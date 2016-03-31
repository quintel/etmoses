include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :load_profile do
    sequence(:key){|n| "key_#{n}"}
    included_in_concurrency true
  end

  factory :load_profile_base_load, class: LoadProfile do
    sequence(:key){|n| "key_#{n}"}
    included_in_concurrency true

    load_profile_components {
      [ create(:load_profile_component_flex),
        create(:load_profile_component_inflex) ]
    }
  end

  factory :load_profile_with_curve, class: LoadProfile do
    sequence(:key) {|n| "key_#{n}_with_curve"}
    included_in_concurrency true

    load_profile_components { build_list :load_profile_component, 1 }
  end
end
