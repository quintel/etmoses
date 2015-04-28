require 'rails_helper'

RSpec.describe Import::ProfileSelector do
  let(:profile_one) { create(:load_profile, key: 'profile_one') }
  let(:profile_two) { create(:load_profile, key: 'profile_two') }

  before do
    TechnologyProfile.create!(
      technology: 'tech_one', load_profile: profile_one)

    TechnologyProfile.create!(
      technology: 'tech_one', load_profile: profile_two)
  end

  let(:selector) { Import::ProfileSelector.new(%w( tech_one tech_two )) }
end # Import::ProfileSelector
