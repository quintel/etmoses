require 'rails_helper'

RSpec.describe Moses do
  describe '#data_dir' do
    it 'returns a Pathname' do
      expect(Moses.data_dir).to be_a(Pathname)
    end
  end

  describe '#data_dir=' do
    around(:each) do |example|
      # Each example is wrapped in with_data_dir to ensure that the original
      # data_dir is restored.
      Moses.with_data_dir('/tmp') { example.run }
    end

    it 'sets the path, given an absolute string' do
      expect { Moses.data_dir = '/tmp/data' }.
        to change { Moses.data_dir }.
        to(Pathname.new('/tmp/data'))
    end

    it 'sets the path, given an absolute pathname' do
      expect { Moses.data_dir = Pathname.new('/tmp/data') }.
        to change { Moses.data_dir }.
        to(Pathname.new('/tmp/data'))
    end

    it 'sets the path, given a relative string' do
      expect { Moses.data_dir = 'data' }.
        to change { Moses.data_dir }.
        to(Rails.root.join('data'))
    end

    it 'sets the path, given a relative pathname' do
      expect { Moses.data_dir = Pathname.new('data') }.
        to change { Moses.data_dir }.
        to(Rails.root.join('data'))
    end
  end # data_dir=

  describe '#with_data_dir' do
    it 'temporarily changes the data directory' do
      Moses.with_data_dir("#{ Rails.root }/tmp") do
        expect(Moses.data_dir.to_s).to eql("#{ Rails.root }/tmp")
      end
    end

    it 'restores the previous directory when finished' do
      originally = Moses.data_dir

      Moses.with_data_dir('/tmp') {}

      expect(Moses.data_dir).to eql(originally)
      expect(Moses.data_dir).to_not eql('/tmp')
    end

    it 'restores the previous directory if an exception happens' do
      originally = Moses.data_dir

      begin
        Moses.with_data_dir('/tmp') { raise 'Nope' }
      rescue StandardError => exception
        raise exception unless exception.message == 'Nope'
      end

      expect(Moses.data_dir).to eql(originally)
      expect(Moses.data_dir).to_not eql('/tmp')
    end
  end
end # describe Moses
