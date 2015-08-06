require 'rails_helper'

RSpec.describe TechnologyComponentBehavior, :type => :model do
  it { expect(subject).to validate_inclusion_of(:curve_type).
         in_array(%w( flex inflex )) }

  it { expect(subject).to validate_inclusion_of(:behavior).
         in_array(Technology::BEHAVIORS) }

  it { expect(subject).to validate_uniqueness_of(:curve_type).
         scoped_to(:technology_id) }
end
