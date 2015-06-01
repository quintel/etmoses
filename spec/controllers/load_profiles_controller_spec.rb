require 'rails_helper'

RSpec.describe LoadProfilesController do
  let(:user){ FactoryGirl.create(:user) }
  let!(:sign_in_user){ sign_in(:user, user) }
  let(:create_load_profile){
    post :create, load_profile: {
      key: "name_1",
      curve: fixture_file_upload("technology_profile.csv", "text/csv")
    }
  }

  it "creating load profiles" do
    create_load_profile

    expect(LoadProfile.count).to eq(1)
  end

  it "load profile belongs to the current user" do
    create_load_profile

    expect(LoadProfile.last.user).to eq(user)
  end
end
