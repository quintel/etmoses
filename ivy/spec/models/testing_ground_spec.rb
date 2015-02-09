require 'rails_helper'

RSpec.describe TestingGround do
  it 'must have a topology set' do
    expect(TestingGround.new.errors_on(:topology)).to include("can't be blank")
  end

  describe 'technolgies' do
    context 'when the user sets no value' do
      it 'is set to an empty hash prior to validation' do
        tg = TestingGround.new
        expect { tg.valid? }.to change { tg.technologies }.from(nil).to({})
      end
    end # when the user sets no value

    context 'with an invalid owner node' do
      it 'is not valid' do
        tg = build(:testing_ground)
        tg.technologies['lv3'] = tg.technologies.delete('lv2')

        expect(tg.errors_on(:technologies)).
          to include('includes a connection to missing node "lv3"')
      end
    end # with an invalid owner node

    context 'with a valid owner node' do
      it 'is valid' do
        expect(build(:testing_ground).errors_on(:technologies)).to be_blank
      end
    end # with a valid owner node

    # Technology types
    # ----------------

    context 'with an undefined technology type' do
      let(:tg) do
        build(:testing_ground, technologies: {
          'lv1' => [{ 'name' => 'No Type' }]
        })
      end

      it 'is valid' do
        expect(tg).to be_valid
      end
    end # with an undefined technology type

    context 'with a defined technology type' do
      let(:tg) do
        build(:testing_ground, technologies: {
          'lv1' => [{ 'name' => 'No Type', 'type' => 'tech_one' }]
        })
      end

      it 'is valid' do
        expect(tg).to be_valid
      end
    end # with a defined technology type

    context 'with a non-existent technology type' do
      let(:tg) do
        build(:testing_ground, technologies: {
          'lv1' => [{ 'name' => 'No Type', 'type' => 'nope' }]
        })
      end

      it 'is not valid' do
        expect(tg.errors_on(:technologies)).
          to include('has an unknown technology type: nope')
      end
    end # with a non-existent technology type

    # Load profiles
    # -------------

    context 'with no load profile set' do
      let(:tg) do
        build(:testing_ground, technologies: {
          'lv1' => [{ 'name' => 'No Type', 'type' => 'tech_one' }]
        })
      end

      it 'is valid' do
        expect(tg).to be_valid
      end
    end # with no load profile set

    context 'with a permitted load profile set' do
      let(:tg) do
        build(:testing_ground, technologies: {
          'lv1' => [{
            'name' => 'No Type', 'type' => 'tech_one',
            'profile' => 'agriculture_chp'
          }]
        })
      end

      it 'is valid' do
        expect(tg).to be_valid
      end
    end # with a permitted load profile set

    context 'with a non-permitted load profile set' do
      let(:tg) do
        build(:testing_ground, technologies: {
          'lv1' => [{
            'name' => 'No Type', 'type' => 'tech_one',
            'profile' => 'buildings_chp'
          }]
        })
      end

      it 'is not valid' do
        expect(tg.errors_on(:technologies)).to include(
          'may not use the "buildings_chp" profile with a "tech_one"')
      end
    end # with a non-permitted load profile set
  end # technologies
end # describe TestingGround
