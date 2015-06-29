require 'rails_helper'

RSpec.describe LoadProfiles::Hierarchy do
  let!(:load_profile_categories){
    parent = LoadProfileCategory.create!(name: "aa", parent_id: 0)
    child  = LoadProfileCategory.create!(name: "aa", parent_id: parent.id)
    child2 = LoadProfileCategory.create!(name: "cc", parent_id: parent.id)
    child3 = LoadProfileCategory.create!(name: "bb", parent_id: parent.id)
    LoadProfileCategory.create!(name: "bb", parent_id: child.id)
  }

  it "sorts correctly" do
    expect(
      LoadProfiles::Hierarchy.new.tree_sort.map do |t|
        t[:load_profile_category].name
      end
    ).to eq(%w(aa aa bb bb cc))
  end
end
