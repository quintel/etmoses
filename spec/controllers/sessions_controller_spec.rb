require 'rails_helper'

RSpec.describe SessionsController do
  it 'visits new sessions path succesfully' do
    get :new

    expect(response.status).to eq(200)
  end

  it "does not login a non-activated user" do
    user = FactoryGirl.create(:user)

    post :create, session: { email: user.email, password: "test123" }

    expect(response).to render_template(:new)
  end

  it "logs in a an ativated user" do
    user = FactoryGirl.create(:user, activated: true)

    post :create, session: { email: user.email, password: "test123" }

    expect(controller.current_user).to eq(user)
  end
end
