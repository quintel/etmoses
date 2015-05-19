include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :load_profile do
    sequence(:key){|n| "key_#{n}"}

    curve_file_name 'my-first-curve.csv'
    curve_content_type 'text/csv'
    curve_file_size 1
  end

  factory :load_profile_with_curve, class: LoadProfile do
    sequence(:key) {|n| "key_#{n}_with_curve"}

    curve {
      fixture_file_upload(
        "#{Rails.root}/spec/fixtures/data/curves/one.csv",
        "text/csv")
    }
  end
end
