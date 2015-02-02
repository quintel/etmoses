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
  end # technologies
end # describe TestingGround
