require 'rails_helper'

RSpec.describe LoadProfilesController do
  let(:user){ FactoryGirl.create(:user) }
  let!(:sign_in_user){ sign_in(user) }

  describe "show a load profile" do
    it "shows a load profile" do
      load_profile = FactoryGirl.create(:load_profile)

      get :show, id: load_profile.id

      expect(response.status).to eq(200)
    end
  end

  describe "creating a load profile" do
    let(:create_load_profile){
      post :create, load_profile: {
        key: "name_1",
        load_profile_components: [{ curve: fixture_file_upload("technology_profile.csv", "text/csv") }]
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

  describe "destroy a load profile" do
    it "destroys a load profile" do
      load_profile = FactoryGirl.create(:load_profile, user: user)

      delete :destroy, id: load_profile.id

      expect(LoadProfile.count).to eq(0)
    end
  end
end
