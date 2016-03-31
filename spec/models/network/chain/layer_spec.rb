require 'rails_helper'

module Network::Chain
  RSpec.describe Layer do
    let(:layer_one)  { Layer.new }
    let(:layer_two)  { Layer.new }
    let(:technology) { ->(*) { load } }

    let(:connection) do
      Connection.new(
        downward: Slot.downward(efficiency: 0.8, capacity: 1.0),
        upward:   Slot.upward(efficiency: 0.5, capacity: 1.0)
      )
    end

    # [ layer_one ] -> [ layer_two ] -> [ technology ]
    context 'with two layers' do
      before do
        layer_one.connect_to(connection)
        connection.connect_to(layer_two)
        layer_two.connect_to(technology)
      end

      context 'and downward efficiency of 0.8, capacity 1.0' do
        context 'and tech load of 0.5' do
          let(:load) { 0.5 }

          it 'has a load of 0.625 on the top layer' do
            expect(layer_one.call(0)).to eql(0.625)
          end

          it 'has a load of 0.625 on the connection' do
            expect(connection.call(0)).to eql(0.625)
          end

          it 'has a load of 0.5 on the bottom layer' do
            expect(layer_two.call(0)).to eql(0.5)
          end
        end

        context 'and tech load of 1.5' do
          let(:load) { 1.5 }

          it 'has a load of 1.0 on the top layer' do
            expect(layer_one.call(0)).to eql(1.0)
          end

          it 'has a load of 1.0 on the connection' do
            expect(connection.call(0)).to eql(1.0)
          end

          it 'has a load of 1.5 on the bottom layer' do
            expect(layer_two.call(0)).to eql(1.5)
          end
        end

        context 'and tech load of 4.0' do
          let(:load) { 4.0 }

          it 'has a load of 1.0 on the top layer' do
            expect(layer_one.call(0)).to eql(1.0)
          end

          it 'has a load of 1.0 on the connection' do
            expect(connection.call(0)).to eql(1.0)
          end

          it 'has a load of 2.0 on the bottom layer' do
            expect(layer_two.call(0)).to eql(4.0)
          end
        end
      end # and downward efficiency of 0.8, capacity 1.0

      context 'and upward efficiency of 0.5, capacity 1.0' do
        context 'and tech load of -0.5' do
          let(:load) { -0.5 }

          it 'has a load of -0.25 on the top layer' do
            expect(layer_one.call(0)).to eql(-0.25)
          end

          it 'has a load of -0.25 on the connection' do
            expect(connection.call(0)).to eql(-0.25)
          end

          it 'has a load of -0.5 on the bottom layer' do
            expect(layer_two.call(0)).to eql(-0.5)
          end
        end

        context 'and tech load of -2.0' do
          let(:load) { -2.0 }

          it 'has a load of -1.0 on the top layer' do
            expect(layer_one.call(0)).to eql(-1.0)
          end

          it 'has a load of -1.0 on the connection' do
            expect(connection.call(0)).to eql(-1.0)
          end

          it 'has a load of -2.0 on the bottom layer' do
            expect(layer_two.call(0)).to eql(-2.0)
          end
        end

        context 'and tech load of -4.0' do
          let(:load) { -4.0 }

          it 'has a load of -1.0 on the top layer' do
            expect(layer_one.call(0)).to eql(-1.0)
          end

          it 'has a load of -1.0 on the connection' do
            expect(connection.call(0)).to eql(-1.0)
          end

          it 'has a load of -2.0 on the bottom layer' do
            expect(layer_two.call(0)).to eql(-4.0)
          end
        end
      end # and upward efficiency of 0.5, capacity 1.0
    end # with two layers

    # [ layer_one ] -> [ layer_two ]
    context 'with two layers, but no technology' do
      before do
        layer_one.connect_to(connection)
        connection.connect_to(layer_two)
      end

      it 'has a load of 0.0 on the top layer' do
        expect(layer_one.call(0)).to eql(0.0)
      end

      it 'has a load of 0.0 on the connection' do
        expect(connection.call(0)).to eql(0.0)
      end

      it 'has a load of 0.0 on the bottom layer' do
        expect(layer_two.call(0)).to eql(0.0)
      end
    end # with two layers, but no technology
  end # Layer
end
