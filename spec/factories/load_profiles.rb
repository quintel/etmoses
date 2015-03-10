include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :load_profile do
    curve {
      fixture_file_upload(
        "#{Rails.root}/spec/fixtures/data/curves/one.csv",
        "text/csv")
    }
  end
end
