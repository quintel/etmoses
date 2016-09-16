require 'rails_helper'

RSpec.describe TestingGround do
  let!(:technology) { create(:technology, key: 'tech_one') }

  it 'must have a topology set' do
    expect(TestingGround.new.errors_on(:topology)).to include("can't be blank")
  end

  describe 'technology profile' do
    context 'when the user sets no value' do
      it 'is set to a TechnologyList when initialized' do
        expect(TestingGround.new.technology_profile).to be_a(TechnologyList)
      end
    end # when the user sets no value

    context 'when the user sets a string value' do
      let(:str)   { '{"lv1":[{"name":"Test"}]}' }
      let(:techs) { TestingGround.new(technology_profile: str).technology_profile }

      it 'sets the TechnologyList' do
        expect(techs).to be_a(TechnologyList)
      end

      it 'sets the technology profile' do
        expect(techs['lv1']).to be_a(Array)
      end
    end # when the user sets a string value

    context 'with an invalid owner node' do
      it 'is not valid' do
        tg = build(:testing_ground)
        tg.technology_profile['lv3'] = tg.technology_profile.delete('lv2')

        expect(tg.errors_on(:technology_profile)).
          to include('includes a connection to missing node "lv3"')
      end
    end # with an invalid owner node

    context 'with a valid owner node' do
      it 'is valid' do
        expect(build(:testing_ground).errors_on(:technology_profile)).to be_blank
      end
    end # with a valid owner node

    # Technology types
    # ----------------

    context 'with an undefined technology type' do
      let(:tg) do
        build(:testing_ground, technology_profile: {
          'lv1' => [{ 'name' => 'No Type' }]
        })
      end

      it 'is valid' do
        expect(tg).to be_valid
      end
    end # with an undefined technology type

    context 'with a defined technology type' do
      let(:tg) do
        build(:testing_ground, technology_profile: {
          'lv1' => [{ 'name' => 'No Type', 'type' => 'base_load' }]
        })
      end

      it 'is valid' do
        expect(tg).to be_valid
      end
    end # with a defined technology type

    context 'with a non-existent technology type' do
      let(:tg) do
        build(:testing_ground, technology_profile: {
          'lv1' => [{ 'name' => 'No Type', 'type' => 'nope' }]
        })
      end

      it 'is not valid' do
        expect(tg.errors_on(:technology_profile)).
          to include('has an unknown technology type: nope')
      end
    end # with a non-existent technology type

    # Load profiles
    # -------------

    context 'with no load profile set' do
      let(:tg) do
        build(:testing_ground, technology_profile: {
          'lv1' => [{ 'name' => 'No Type', 'type' => 'base_load' }]
        })
      end

      it 'is valid' do
        expect(tg).to be_valid
      end

      it 'may have a :capacity' do
        tg.technology_profile['lv1'].first.capacity = 5.0
        expect(tg).to be_valid
      end
    end # with no load profile set

    context 'with a permitted load profile set' do
      let(:tg) do
        create(:load_profile, key: 'one')

        build(:testing_ground, technology_profile: {
          'lv1' => [{
            'name' => 'No Type', 'type' => 'base_load', 'profile' => 'one'
          }]
        })
      end

      it 'is valid' do
        expect(tg).to be_valid
      end

      it 'may have a :capacity' do
        tg.technology_profile['lv1'].first.capacity = 5.0
        expect(tg).to be_valid
      end
    end # with a permitted load profile set

    pending 'with a non-permitted load profile set' do
      let(:tg) do
        build(:testing_ground, technology_profile: {
          'lv1' => [{
            'name' => 'No Type', 'type' => 'base_load',
            'profile' => 'buildings_chp'
          }]
        })
      end

      it 'is not valid' do
        expect(tg.errors_on(:technology_profile)).to include(
          'may not use the "buildings_chp" profile with a "tech_one"')
      end
    end # with a non-permitted load profile set

    context 'with an inline profile' do
      let(:tg) do
        build(:testing_ground, technology_profile: {
          'lv1' => [{
            'name' => 'No Type', 'type' => 'base_load', 'profile' => profile
          }]
        })
      end

      context 'with float contents' do
        let(:profile) { [1.0, 2.0, 3.0] }

        it 'assigns the profile' do
          expect(tg).to be_valid
        end
      end # with float contents

      context 'with integer contents' do
        let(:profile) { [1, 2, 3] }

        it 'assigns the profile' do
          expect(tg).to be_valid
        end
      end # with integer contents

      context 'with an empty element' do
        let(:profile) { [1, nil, 3] }

        it 'is not valid' do
          expect(tg.errors_on(:technology_profile)).to include(
            'may not have an inline curve with non-numeric values (on Household)')
        end
      end # with an empty element

      context 'with a non-numeric element' do
        let(:profile) { [1, 'what', 3] }

        it 'is not valid' do
          expect(tg.errors_on(:technology_profile)).to include(
            'may not have an inline curve with non-numeric values (on Household)')
        end
      end # with a non-numeric element
    end # with an inline profile

    # Number of units
    # ---------------

    context 'with units=0' do
      let(:tg) do
        build(:testing_ground, technology_profile: {
          'lv1' => [{ 'name' => 'No Type', units: 0 }]
        })
      end

      it 'is valid' do
        expect(tg).to be_valid
      end
    end # with units=0

    context 'with units=2.5' do
      let(:tg) do
        build(:testing_ground, technology_profile: {
          'lv1' => [{ 'name' => 'No Type', units: 2.5 }]
        })
      end

      it 'is valid' do
        expect(tg).to be_valid
      end
    end # with units=2.5

    context 'with units=-1' do
      let(:tg) do
        build(:testing_ground, technology_profile: {
          'lv1' => [{ 'name' => 'No Type', units: -1 }]
        })
      end

      it 'is not valid' do
        expect(tg.errors_on(:technology_profile)).
          to include('may not have fewer than zero units')
      end
    end # with units=2.5
  end # technology profile

  describe '.visible_to' do
    def les(visible, user, topology, market_model)
      create(
        :testing_ground,
        user: user,
        public: visible,
        market_model: market_model,
        topology: topology
      )
    end

    let!(:user) { create(:user) }

    let(:public_mm)   { create(:market_model, user: user, public: true) }
    let(:private_mm)  { create(:market_model, user: user, public: false) }

    let(:public_top)  { create(:topology, user: user, public: true) }
    let(:private_top) { create(:topology, user: user, public: false) }

    let!(:les_public)      { les(true, user, public_top, public_mm) }
    let!(:les_private)     { les(false, user, public_top, public_mm) }
    let!(:les_private_mm)  { les(true, user, public_top, private_mm) }
    let!(:les_private_top) { les(true, user, private_top, public_mm) }

    context 'given a user' do
      it 'includes their public LESes' do
        expect(described_class.visible_to(user)).to include(les_public)
      end

      it 'includes their private LESes' do
        expect(described_class.visible_to(user)).to include(les_private)
      end

      it 'includes their public LESes with private market models' do
        expect(described_class.visible_to(user)).to include(les_private_mm)
      end

      it 'includes their public LESes with private topologies' do
        expect(described_class.visible_to(user)).to include(les_private_mm)
      end
    end # given a user

    context 'given a user who does not own the LES' do
      let(:other_user) { create(:user) }

      it 'includes public LESes' do
        expect(described_class.visible_to(other_user)).to include(les_public)
      end

      it 'excludes other user private LESes' do
        expect(described_class.visible_to(other_user))
          .not_to include(les_private)
      end

      it 'excludes other users public LESes with private market models' do
        expect(described_class.visible_to(other_user))
          .not_to include(les_private_mm)
      end

      it 'excludes other users public LESes with private topologies' do
        expect(described_class.visible_to(other_user))
          .not_to include(les_private_mm)
      end
    end # givena user who does not own the LES

    context 'given no user' do
      it 'includes public LESes' do
        expect(described_class.visible_to(nil)).to include(les_public)
      end

      it 'excludes other user private LESes' do
        expect(described_class.visible_to(nil))
          .not_to include(les_private)
      end

      it 'excludes other users public LESes with private market models' do
        expect(described_class.visible_to(nil))
          .not_to include(les_private_mm)
      end

      it 'excludes other users public LESes with private topologies' do
        expect(described_class.visible_to(nil))
          .not_to include(les_private_mm)
      end
    end # givena user who does not own the LES
  end # visible_to
end # describe TestingGround
