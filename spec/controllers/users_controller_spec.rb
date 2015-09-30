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
end
