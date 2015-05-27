require 'rails_helper'

RSpec.describe ImportableAttribute do
  it do
    expect(subject).to validate_inclusion_of(:name)
      .in_array(%w(
        demand electricity_output_capacity input_capacity
      ))
  end

  it 'is deleted with the parent technology' do
    tech = create(:importable_technology, key: 'hi')

    # This tech's attribute should not be deleted.
    create(:importable_technology, key: 'another')

    expect { tech.destroy }.to change { ImportableAttribute.count }.by(-1)
  end
end
