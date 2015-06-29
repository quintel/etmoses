require 'rails_helper'

RSpec.describe LoadProfileCategory do
  let(:parent){ LoadProfileCategory.create! }
  let!(:child){ LoadProfileCategory.create!(parent_id: parent.id) }
  let(:subchild){ LoadProfileCategory.create!(parent_id: child.id) }
  let(:load_profile){
    FactoryGirl.create(:load_profile, load_profile_category: child)
  }

  it "has children" do
    expect(parent.children).to include(child)
  end

  it "has a parent" do
    expect(child.parent).to eq(parent)
  end

  it "has many load profiles" do
    expect(child.load_profiles).to include(load_profile)
  end
end
