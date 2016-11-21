require 'rails_helper'

RSpec.describe Finance::BusinessCaseSummary do
  let(:financials){
    [ { 'aggregator'      => [0,   nil, nil,      nil, nil, nil, nil] },
      { 'cooperation'     => [nil, 0,   nil,      nil, nil, nil, nil] },
      { 'customer'        => [nil, nil, 0,        nil, nil, nil, nil] },
      { 'government'      => [nil, nil, nil,      0,   nil, nil, nil] },
      { 'producer'        => [nil, nil, nil,      nil, 0,   nil, nil] },
      { 'supplier'        => [nil, nil, nil,      nil, nil, 0,   nil] },
      { 'system operator' => [nil, nil, 44_150.4, nil, nil, nil, 9998] },
      { 'freeform'        => { 'system operator' => 0 } } ]
  }

  let(:business_case) do
    FactoryGirl.create(:business_case, financials: financials)
  end

  let(:presenter) do
    Finance::BusinessCaseCSVPresenter.new(business_case)
  end

  let(:csv) do
    CSV.parse(presenter.to_csv, headers: true, converters: [:float])
  end

  it 'has each summary header' do
    expect(csv.headers).to eq(%w(Stakeholder Incoming Outgoing Freeform Total))
  end

  it 'summarises each stakeholder' do
    expected = financials.flat_map(&:keys).uniq - %w(freeform)
    stakeholders = csv.map { |row| row['Stakeholder'] }

    expect(stakeholders).to eq(expected)
  end

  it 'includes the prices for each stakeholder' do
    row = csv.detect { |row| row['Stakeholder'] == 'system operator' }

    expect(row).to be
    expect(row['Incoming']).to eq(44_150.4)
    expect(row['Outgoing']).to eq(9998.0)
    expect(row['Freeform']).to be_zero
    expect(row['Total']).to eq(34152.4)
  end
end
