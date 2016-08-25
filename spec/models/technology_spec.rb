require 'rails_helper'

RSpec.describe Technology, type: :model do
  it "raises an error when fetching an unknown technology" do
    expect {
      Technology.by_key("non-existing-technology")
    }.to raise_error(ActiveRecord::RecordNotFound)
  end
end # Technology
