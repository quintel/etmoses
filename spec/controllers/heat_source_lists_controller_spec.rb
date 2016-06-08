require 'rails_helper'

RSpec.describe HeatSourceListsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:testing_ground) { FactoryGirl.create(:testing_ground, user: user) }
  let!(:sign_in_user) { sign_in(user) }
  let(:asset_list) { [] }

  describe "#update.js" do
    let(:heat_source_list) {
      FactoryGirl.create(:heat_source_list, testing_ground: testing_ground)
    }

    it "update heat source list" do
      put :update, id: heat_source_list.id,
                   testing_ground_id: testing_ground.id,
                   heat_source_list: { asset_list: '[]' },
                   format: :js

      expect(heat_source_list.asset_list).to eq([])
    end
  end
end
