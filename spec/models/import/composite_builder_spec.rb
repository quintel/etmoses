require 'rails_helper'

RSpec.describe Import::CompositeBuilder do
  it 'creates a set of composites' do
    expect(Import::CompositeBuilder.new({
      'value' => '1.0', 'area_attribute' => 'number_of_residences'}).build.map{|t| t['name'] }).to eq([
        'Buffer space heating', 'Buffer water heating'
    ])
  end
end
