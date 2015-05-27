require 'rails_helper'

RSpec.describe ImportableAttribute do
  it do
    expect(subject).to validate_inclusion_of(:name)
      .in_array(%w(
        demand electricity_output_capacity input_capacity
      ))
  end
end
