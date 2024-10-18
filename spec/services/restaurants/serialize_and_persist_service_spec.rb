require 'rails_helper'
require_relative '../../fixtures/hashes/serialize_and_persist_hashes' 

module Restaurants
  RSpec.describe SerializeAndPersistService, type: :service do
    describe '#call' do
      let(:not_a_hash) { [] }
      let(:empty_hash) { {} }
      let(:empty_restaurants_hash) { { "restaurants": []} }
      let(:restaurants_is_not_an_array_hash) { { "restaurants": {}} }
      let(:invalid_keys_hash) { INVALID_KEY_HASH }
      let(:valid_hash) { VALID_HASH }

      context 'when the input data is not a hash' do
        subject { described_class.new(not_a_hash) }

        it 'raises an ArgumentError' do
          expect { subject.call }.to raise_error(ArgumentError, "Invalid data format. It should be a Hash.")
        end
      end

      context 'when the input data is empy/blank' do
        subject { described_class.new(empty_hash) }

        it 'raises an ArgumentError' do
          expect { subject.call }.to raise_error(ArgumentError, "No restaurants found in the give JSON data.")
        end
      end

      context 'when the input data has no restaurants' do
        subject { described_class.new(empty_restaurants_hash) }

        it 'raises an ArgumentError' do
          expect { subject.call }.to raise_error(ArgumentError, "No restaurants found in the give JSON data.")
        end
      end

      context 'when the restaurants is not an array' do
        subject { described_class.new(restaurants_is_not_an_array_hash) }

        it 'raises an ArgumentError' do
          expect { subject.call }.to raise_error(ArgumentError, "No restaurants found in the give JSON data.")
        end
      end

      context 'when the input data has invalid keys/attributess' do
        subject { described_class.new(invalid_keys_hash) }

        it 'raises an ArgumentError' do
          expect { subject.call }.to raise_error(ArgumentError, "Invalid formar Data. Unpermitted Menu attributes: dishes")
        end
      end

      
      context 'when the input data is valid' do        
        subject { described_class.new(valid_hash) }

        it 'returns an array of logs' do          
          result = subject.call
          expect(result).to be_present
          expect(result).to be_an_instance_of(Array)
        end
      end
    end
  end
end