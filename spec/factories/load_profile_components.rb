include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :load_profile_component do
    curve_type 'flex'
    curve {
      fixture_file_upload("#{Rails.root}/spec/fixtures/data/curves/one.csv", "text/csv")
    }
  end
end
