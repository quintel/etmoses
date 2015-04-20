require 'rails_helper'

RSpec.describe SessionsController do
  it 'visits new sessions path succesfully' do
    get :new

    expect(response.status).to eq(200)
  end

  it "logs in a user" do
    user = FactoryGirl.create(:user)

    post :create, session: { email: user.email, password: "test123" }

    expect(controller.current_user).to eq(user)
  end
end
