require 'rails_helper'

RSpec.describe Import::ProfileSelector do
  let(:profile_one) { create(:load_profile, key: 'profile_one') }
  let(:profile_two) { create(:load_profile, key: 'profile_two') }

  before do
    PermittedTechnology.create!(
      technology: 'tech_one', load_profile: profile_one)

    PermittedTechnology.create!(
      technology: 'tech_one', load_profile: profile_two)
  end

  let(:selector) { Import::ProfileSelector.new(%w( tech_one tech_two )) }

  context 'selecting for "tech_one" (2 profiles) and "tech_two" (0 profiles)' do
    context 'for "tech_one"' do
      let(:enum) { selector.for_tech('tech_one') }

      it 'selects the first profile' do
        expect(enum.next).to eq('profile_one')
      end

      it 'selects the second profile' do
        enum.next
        expect(enum.next).to eq('profile_two')
      end

      it 'loops infinitely' do
        expect(enum.take(4)).to eq(
          %w( profile_one profile_two profile_one profile_two ))
      end
    end # for "tech_one"

    context 'for "tech_two"' do
      let(:enum) { selector.for_tech('tech_two') }

      it 'selects nothing on the first call' do
        expect(enum.next).to eq(nil)
      end

      it 'selects nothing on the second call' do
        enum.next
        expect(enum.next).to eq(nil)
      end

      it 'loops infinitely' do
        expect(enum.take(4)).to eq([nil, nil, nil, nil])
      end
    end # for "tech_one"
  end # selecting for "tech_one" (2 profiles) and "tech_two" (0 profiles)
end # Import::ProfileSelector
