require 'rails_helper'

RSpec.describe LoadProfilesController do
  let(:user){ FactoryGirl.create(:user) }
  let!(:sign_in_user){ sign_in(:user, user) }

  describe "show a load profile" do
    it "shows a load profile" do
      load_profile = FactoryGirl.create(:load_profile)

      get :show, id: load_profile.id

      expect(response.status).to eq(200)
    end
  end

  describe "creating a load profile" do
    let!(:create_load_profile){
      post :create, load_profile: {
        key: "name_1",
        load_profile_components_attributes: [{
          curve: fixture_file_upload("technology_profile.csv", "text/csv"),
          curve_type: 'flex'
        }]
      }
    }

    it "creating load profiles" do
      expect(LoadProfile.count).to eq(1)
    end

    it "load profile belongs to the current user" do
      expect(LoadProfile.last.user).to eq(user)
    end

    it "expects a single load profile component" do
      expect(LoadProfileComponent.count).to eq(1)
    end
  end

  describe "creating a load profile on a windows machine" do
    let!(:create_load_profile){
      post :create, load_profile: {
        key: "name_1",
        load_profile_components_attributes: [{
          curve: fixture_file_upload("windows_profile.csv", "application/octet-stream"),
          curve_type: 'flex'
        }]
      }
    }

    it "creates the correct load profile component" do
      load_profile_component = LoadProfileComponent.last

      expect(JSON.parse(load_profile_component.to_json)["values"].length).to eq(35040)
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
