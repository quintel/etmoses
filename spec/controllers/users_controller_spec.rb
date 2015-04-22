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
        password: "test123"
      }
    end

    it "creates a user" do
      expect(response).to redirect_to(root_path)
    end

    it "sends a mail to chael" do
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    it "is not activated" do
      expect(User.last.activated).to eq(false)
    end
  end

  describe "creating a faulty user" do
    it "posting a blank form" do
      post :create, registration_form: { email: "", password: "" }

      expect(response).to render_template(:new)
    end
  end
end
