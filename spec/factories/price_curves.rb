include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :price_curve do
    sequence(:key){|n| "key_#{n}"}
  end

  factory :price_curve_with_curve, class: PriceCurve do
    sequence(:key) {|n| "key_#{n}_with_curve"}

    curve do
      fixture_file_upload(
        "#{Rails.root}/spec/fixtures/data/curves/one.csv", "text/csv")
    end
  end
end
