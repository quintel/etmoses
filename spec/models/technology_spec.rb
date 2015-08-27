require 'rails_helper'

RSpec.describe Technology, type: :model do
  it { expect(subject).to validate_presence_of(:key) }
  it { expect(subject).to validate_length_of(:key).is_at_most(100) }
  it { expect(subject).to validate_uniqueness_of(:key) }

  it { expect(subject).to validate_length_of(:name).is_at_most(100) }

  it { expect(subject).to validate_inclusion_of(:behavior).
         in_array(Technology::BEHAVIORS) }

  it { expect(subject).to validate_length_of(:export_to).is_at_most(100) }

  it { expect(subject).to have_many(:importable_attributes).dependent(true) }
  it { expect(subject).to have_many(:technology_profiles).dependent(true) }
  it { expect(subject).to have_many(:component_behaviors).dependent(true) }

  describe '#name' do
    context 'when an name is assigned' do
      it 'uses the assigned name' do
        expect(Technology.new(name: 'Okay', key: 'this').name).to eq('Okay')
      end
    end # when an name is assigned

    context 'when no name is assigned' do
      it 'uses a variation of the key' do
        expect(Technology.new(key: 'this_thing').name).to eq('This thing')
      end
    end # when an name is assigned
  end # name
end # Technology
