include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :profile_curve do
    curve_type 'Flexible'
    curve {
      fixture_file_upload("#{Rails.root}/spec/fixtures/data/curves/one.csv", "text/csv")
    }
  end
end
