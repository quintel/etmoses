include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :load_profile_component do
    curve_type 'flex'
    curve {
      fixture_file_upload("#{Rails.root}/spec/fixtures/data/curves/one.csv", "text/csv")
    }
  end

  factory :load_profile_component_flex, class: LoadProfileComponent do
    curve_type 'flex'
    curve {
      fixture_file_upload("#{Rails.root}/spec/fixtures/data/curves/flex.csv", "text/csv")
    }
  end

  factory :load_profile_component_inflex, class: LoadProfileComponent do
    curve_type 'inflex'
    curve {
      fixture_file_upload("#{Rails.root}/spec/fixtures/data/curves/inflex.csv", "text/csv")
    }
  end
end
