require 'rails_helper'

RSpec.describe Technology, type: :model do
  it { expect(subject).to validate_presence_of(:key) }
  it { expect(subject).to validate_length_of(:key).is_at_most(100) }
  it { expect(subject).to validate_uniqueness_of(:key) }
  it { expect(subject).to validate_exclusion_of(:key).in_array(%w( generic )) }

  it { expect(subject).to validate_length_of(:name).is_at_most(100) }

  it { expect(subject).to validate_length_of(:import_from).is_at_most(50) }
  it { expect(subject).to validate_inclusion_of(:import_from).
         in_array(%w(demand electricity_output_capacity input_capacity)) }

  it { expect(subject).to validate_length_of(:export_to).is_at_most(100) }
end
