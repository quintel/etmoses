require 'rails_helper'

RSpec.describe InstalledHeatSource do
  describe '#profile_curve' do
    let(:load_profile) { create(:load_profile_with_curve) }
    let(:source)       { InstalledHeatSource.new(attrs) }
    let(:attrs)        { {} }
    let(:curve)        { source.profile_curve.curves['default'] }

    context 'when the source is must-run' do
      let(:attrs) { super().merge(dispatchable: false) }

      context 'with production' do
        let(:attrs) { super().merge(heat_production: 8760.0) }

        context 'and a LoadProfile-based curve' do
          before      { source.profile = load_profile.id }

          it 'scales without units' do
            expect(curve.at(0)).to be_within(1e-3).of(0.5)
            expect(curve.at(1)).to be_within(1e-3).of(1)
          end

          it 'scales with units' do
            source.units = 2.0

            expect(curve.at(0)).to be_within(1e-3).of(1)
            expect(curve.at(1)).to be_within(1e-3).of(2)
          end
        end # and a LoadProfile-based curve

        context 'with no profile' do
          it 'has no profile_curve' do
            expect(curve).to be_nil
          end
        end # with no profile
      end # with production

      context 'with no production set' do
        context 'and a LoadProfile-based curve' do
          before      { source.profile = load_profile.id }
          let(:curve) { source.profile_curve.curves['default'] }

          it 'has a profile curve' do
            expect(curve).to be_a(Network::Curve)
          end

          it 'it sets each curve value to zero' do
            expect(curve.at(0)).to eq(0.0)
            expect(curve.at(1)).to eq(0.0)
          end
        end

        context 'and no profile' do
          it 'has no profile curve' do
            expect(curve).to be_nil
          end
        end
      end # with no production set
    end # when the source is must-run
  end # profile_curve
end # InstalledHeatSource
