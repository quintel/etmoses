require 'rails_helper'

RSpec.describe TestingGround::SaveAs do
  let(:original) { FactoryGirl.create(:testing_ground) }
  let(:user)     { FactoryGirl.create(:user) }

  context 'with an LES, name, and user' do
    let(:duplicate) do
      TestingGround::SaveAs.run(original, 'New name', user).reload
    end

    it 'clones the testing ground' do
      expect(duplicate.id).to_not eq(original.id)
    end

    it 'sets the new name' do
      expect(duplicate.name).to eq('New name')
    end

    it 'sets the new owner' do
      expect(duplicate.user).to eq(user)
    end
  end # with an LES, name, and user

  context 'with no name given' do
    let(:duplicate) do
      TestingGround::SaveAs.run(original, nil, user).reload
    end

    it 'raises an error' do
      expect { duplicate.id }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end # with no name given

  context 'with no user given' do
    let(:duplicate) do
      TestingGround::SaveAs.run(original, 'New name', nil).reload
    end

    it 'retains the original user' do
      expect(duplicate.user).to eq(original.user)
    end
  end # with no user given

  relations = TestingGround.reflections.values
    .select { |r| r.macro == :has_one }.map(&:name)

  relations.each do |name|
    context "when the LES has a #{ name.to_s.humanize }" do
      let!(:"original_rel") do
        FactoryGirl.create(name, testing_ground: original)
      end

      let(:duplicate) do
        TestingGround::SaveAs.run(original, 'Name', user).reload
      end

      it "creates a #{ name.to_s.humanize }" do
        expect(duplicate.public_send(name)).to be
      end

      it 'duplicates the business case' do
        expect(duplicate.public_send(name).id)
          .to_not eq(original.public_send(name).id)
      end
    end
  end
end
