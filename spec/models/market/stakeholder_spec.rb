require 'rails_helper'

RSpec.describe Market::Stakeholder do
  let(:stakeholder) { Market::Stakeholder.new('Consumer') }

  it 'has a key' do
    expect(stakeholder.key).to eq('Consumer')
  end

  it 'connects to other stakeholders via a Relation' do
    another = Market::Stakeholder.new('Another')
    edge    = stakeholder.connect_to(another)

    expect(edge).to be_kind_of(Market::Relation)
  end
end
