require 'rails_helper'

RSpec.describe Ivy do
  describe '#data_dir' do
    it 'returns a Pathname' do
      expect(Ivy.data_dir).to be_a(Pathname)
    end
  end

  describe '#data_dir=' do
    around(:each) do |example|
      # Each example is wrapped in with_data_dir to ensure that the original
      # data_dir is restored.
      Ivy.with_data_dir('/tmp') { example.run }
    end

    it 'sets the path, given an absolute string' do
      expect { Ivy.data_dir = '/tmp/data' }.
        to change { Ivy.data_dir }.
        to(Pathname.new('/tmp/data'))
    end

    it 'sets the path, given an absolute pathname' do
      expect { Ivy.data_dir = Pathname.new('/tmp/data') }.
        to change { Ivy.data_dir }.
        to(Pathname.new('/tmp/data'))
    end

    it 'sets the path, given a relative string' do
      expect { Ivy.data_dir = 'data' }.
        to change { Ivy.data_dir }.
        to(Rails.root.join('data'))
    end

    it 'sets the path, given a relative pathname' do
      expect { Ivy.data_dir = Pathname.new('data') }.
        to change { Ivy.data_dir }.
        to(Rails.root.join('data'))
    end
  end # data_dir=

  describe '#with_data_dir' do
    it 'temporarily changes the data directory' do
      Ivy.with_data_dir("#{ Rails.root }/tmp") do
        expect(Ivy.data_dir.to_s).to eql("#{ Rails.root }/tmp")
      end
    end

    it 'restores the previous directory when finished' do
      originally = Ivy.data_dir

      Ivy.with_data_dir('/tmp') {}

      expect(Ivy.data_dir).to eql(originally)
      expect(Ivy.data_dir).to_not eql('/tmp')
    end

    it 'restores the previous directory if an exception happens' do
      originally = Ivy.data_dir

      begin
        Ivy.with_data_dir('/tmp') { raise 'Nope' }
      rescue StandardError => exception
        raise exception unless exception.message == 'Nope'
      end

      expect(Ivy.data_dir).to eql(originally)
      expect(Ivy.data_dir).to_not eql('/tmp')
    end
  end
end # describe Ivy
