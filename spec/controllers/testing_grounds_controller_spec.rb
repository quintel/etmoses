require 'rails_helper'

RSpec.describe TestingGroundsController do
  it "visits the import path" do
    get :import

    expect(response.status).to eq(200)
  end
end
