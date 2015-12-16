require 'rails_helper'

RSpec.describe UsersController do
  it "visits the new page" do
    get :new

    expect(response.status).to eq(200)
  end

  describe "creating a user" do
    before do
      post :create, registration_form: {
        email: "gerard@grdw.nl",
        password: "test123",
        password_confirmation: "test123"
      }
    end

    it "creates a user" do
      expect(response).to redirect_to(root_path)
    end
  end

  describe "creating a faulty user" do
    it "posting a blank form" do
      post :create, registration_form: { email: "", password: "" }

      expect(response).to render_template(:new)
    end
  end

  describe "visiting edit page" do
    it "can't visit edit page without signing in" do
      get :edit

      expect(response).to redirect_to(new_user_session_path)
    end

    it "visits edit page when signed in" do
      user = FactoryGirl.create(:user)
      sign_in(:user, user)
      get :edit

      expect(response.status).to eq(200)
    end
  end

  describe "editing a user" do
    it "posting a blank form" do
      user = FactoryGirl.create(:user)
      sign_in(:user, user)

      post :update, users_form: { email: "", password: "" }

      expect(response).to render_template(:edit)
    end

    it "changing your e-mail adress" do
      user = FactoryGirl.create(:user)
      sign_in(:user, user)

      post :update, users_form: { email: "test@quintel45.com", password: "" }

      expect(user.reload.email).to eq("test@quintel45.com")
    end

    it "changing your password incorrectly" do
      user = FactoryGirl.create(:user)
      sign_in(:user, user)

      post :update, users_form: { email: user.email, password: "1234", password_confirmation: "12345" }

      expect(response).to render_template(:edit)
    end

    it "changing your password" do
      user = FactoryGirl.create(:user)
      sign_in(:user, user)

      post :update, users_form: { email: user.email, password: "1234", password_confirmation: "1234" }

      expect(user.encrypted_password).to_not eq(user.reload.encrypted_password)
    end
  end
end
