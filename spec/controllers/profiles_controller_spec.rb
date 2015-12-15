require 'rails_helper'

RSpec.describe ProfilesController do
  describe "index" do
    it "fetches index page" do
      get :index

      expect(response.status).to eq(200)
    end
  end
end
