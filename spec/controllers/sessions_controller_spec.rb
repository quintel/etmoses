require 'rails_helper'

RSpec.describe SessionsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  it 'visits new sessions path succesfully' do
    get :new

    expect(response.status).to eq(200)
  end

  it "does not login a non-activated user" do
    user = FactoryGirl.create(:user)

    post :create, session: { email: user.email, password: "test123" }

    expect(response).to render_template(:new)
    expect(controller.current_user).to_not eq(user)
  end

  it "logs in a an ativated user" do
    user = FactoryGirl.create(:user, activated: true, password: "test123")

    post :create, session: { email: user.email, password: "test123" }

    expect(controller.current_user).to eq(user)
  end

  it "destroys a user session" do
    user = FactoryGirl.create(:user, activated: true)
    sign_in(:user, user)

    delete :destroy

    expect(controller.current_user).to eq(nil)
  end
end
