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

  context 'when the LES has a business case' do
    let!(:original_business_case) do
      FactoryGirl.create(:business_case, testing_ground: original)
    end

    let(:duplicate) do
      TestingGround::SaveAs.run(original, 'Name', user).reload
    end

    it 'creates a business case' do
      expect(duplicate.business_case).to be
    end

    it 'duplicates the business case' do
      expect(duplicate.business_case.id).to_not eq(original.business_case.id)
    end
  end # when the LES has a business case

  context 'when the LES has a selected strategy' do
    let!(:original_strategy) do
      FactoryGirl.create(:selected_strategy, testing_ground: original)
    end

    let(:duplicate) do
      TestingGround::SaveAs.run(original, 'Name', user).reload
    end

    it 'creates a selected strategy' do
      expect(duplicate.selected_strategy).to be
    end

    it 'duplicates the selected strategy' do
      expect(duplicate.selected_strategy.id).
        to_not eq(original.selected_strategy.id)
    end
  end # when the LES has a selected strategy

  context 'when the LES has a gas asset list' do
    let!(:original_assets) do
      FactoryGirl.create(:gas_asset_list, testing_ground: original)
    end

    let(:duplicate) do
      TestingGround::SaveAs.run(original, 'Name', user).reload
    end

    it 'creates a gas asset list' do
      expect(duplicate.gas_asset_list).to be
    end

    it 'duplicates the gas asset list' do
      expect(duplicate.gas_asset_list.id).
        to_not eq(original.gas_asset_list.id)
    end
  end # when the LES has a gas asset list

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
end
