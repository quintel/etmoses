require 'rails_helper'

RSpec.describe TestingGroundsController do
  it "visits the import path" do
    user = FactoryGirl.create(:user)
    sign_in(user)

    get :import

    expect(response.status).to eq(200)
  end
end
