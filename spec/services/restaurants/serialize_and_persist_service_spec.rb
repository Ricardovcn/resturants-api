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
      let(:invalid_restaurant_missing_name) { INVALID_RESTAURANT_MISSING_NAME }
      let(:invalid_menu_missing_name) { INVALID_MENU_MISSING_NAME }
      let(:invalid_restaurant_extra_attribute) { INVALID_RESTAURANT_EXTRA_ATTRIBUTES }
      let(:invalid_menu_item_invalid_price) { INVALID_MENU_ITEM_INVALID_PRICE }

      let(:valid_restaurant_complete) { VALID_RESTAURANT_COMPLETE }
      let(:valid_restaurant_multiple_menus) { VALID_RESTAURANT_MULTIPLE_MENUS }
      let(:valid_restaurant_extra_attributes) { VALID_RESTAURANT_EXTRA_ATTRIBUTES }
      let(:valid_menu_missing_items) { VALID_MENU_MISSING_ITEMS }
      let(:valid_restauran_missing_menus) { VALID_RESTAURANT_MISSING_MENUS }
      
      context 'when the input data is not a hash' do
        subject { described_class.new(not_a_hash) }

        it 'returns a Failed result and a array of logs' do
          result = subject.call

          expect(result[:success]).to be(false) 
          expect(result[:logs].last[:messages]).to include("Invalid data format. It should be a Hash.")
        end
      end

      context 'when the input data is empy/blank' do
        subject { described_class.new(empty_hash) }

        it 'returns a Failed result and a array of logs' do
          result = subject.call

          expect(result[:success]).to be(false) 
          expect(result[:logs].last[:messages]).to include("No restaurants found in the give JSON data.")
        end
      end

      context 'when the input data has no restaurants' do
        subject { described_class.new(empty_restaurants_hash) }

        it 'returns a Failed result and a array of logs' do
          result = subject.call

          expect(result[:success]).to be(false) 
          expect(result[:logs].last[:messages]).to include("No restaurants found in the give JSON data.")
        end
      end

      context 'when the restaurants is not an array' do
        subject { described_class.new(restaurants_is_not_an_array_hash) }

        it 'returns a Failed result and a array of logs' do
          result = subject.call

          expect(result[:success]).to be(false) 
          expect(result[:logs].last[:messages]).to include("No restaurants found in the give JSON data.")
        end
      end

      context 'when the input data has invalid keys/attributess' do
        subject { described_class.new(invalid_keys_hash) }

        it 'returns a Failed result and a array of logs' do
          result = subject.call

          expect(result[:success]).to be(false) 
          expect(result[:logs].last[:messages]).to include("Invalid format Data. Unpermitted Menu attributes: dishes")
        end
      end

      context 'when the restaurant has an extra and invalid attribute' do
        subject { described_class.new(invalid_restaurant_extra_attribute) }

        it 'returns a Failed result and a array of logs' do
          result = subject.call

          expect(result[:success]).to be(false) 
          expect(result[:logs].last[:messages]).to include("Invalid format Data. Unpermitted Restaurant attributes: extra_info")
        end
      end

      context 'Pass data format validation' do
        restaurant_double = Restaurant.new
        menu_double = Menu.new
        menu_item_double = MenuItem.new
        menu_item_menu_double = MenuItemMenu.new

        before do
          allow(Restaurant).to receive(:new).and_return(restaurant_double)
          allow(Menu).to receive(:new).and_return(menu_double)
          allow(MenuItem).to receive(:new).and_return(menu_item_double)
          allow(MenuItemMenu).to receive(:new).and_return(menu_item_menu_double)
      
          allow(restaurant_double).to receive(:save).and_return(true)
          allow(menu_double).to receive(:save).and_return(true)
          allow(menu_item_double).to receive(:save).and_return(true)
          allow(MenuItem).to receive(:find_by_name).and_return(nil)
          allow(menu_item_menu_double).to receive(:save).and_return(true)
          allow(MenuItemMenu).to receive(:find_by).and_return(nil)
        end

        context 'when the restaurant is missing required parameters' do
          subject { described_class.new(invalid_restaurant_missing_name) }
          
          it 'returns a Failed result and a array of logs' do
            allow(restaurant_double).to receive(:save).and_return(false)

            result = subject.call
  
            expect(result[:success]).to be(false) 
            expect(result[:logs].last[:messages]).to include("Failed to create Restaurant . ")
          end
        end

        context 'when the menu is missing required parameters' do
          subject { described_class.new(invalid_menu_missing_name) }
  
          it 'returns a Failed result and a array of logs' do
            allow(menu_double).to receive(:save).and_return(false)

            result = subject.call
  
            expect(result[:success]).to be(false)             
            expect(result[:logs][-2][:messages]).to include("Failed to create Menu . ")
            expect(result[:logs].last[:messages]).to include("Rolling back database changes.")
          end
        end

        context 'when a object gets an invalid argument parameters' do
          subject { described_class.new(invalid_menu_item_invalid_price) }
          let(:error_message) { "error_message" } 

          it 'returns a Failed result and a array of logs' do
            allow(MenuItem).to receive(:new).and_raise(ArgumentError.new(error_message))

            result = subject.call         
  
            expect(result[:success]).to be(false) 
            expect(result[:logs].last[:messages]).to include("Rolling back database changes due to error (#{ error_message }).")
          end
        end
        
        context 'when the input data is valid' do        
          subject { described_class.new(valid_restaurant_complete) }

          it 'returns an array of logs' do
            result = subject.call
            expect(result).to be_present
            expect(result).to be_an_instance_of(Hash)
            expect(result[:success]).to be(true)
            expect(result[:logs]).to be_present
            expect(result[:logs]).to  be_an_instance_of(Array)
          end
        end

        context 'when the restaurant have more than one menu' do        
          subject { described_class.new(valid_restaurant_multiple_menus) }

          it 'returns an array of logs' do        
            expect(restaurant_double).to receive(:save).once   
            expect(menu_double).to receive(:save).twice   
            
            result = subject.call
            
            expect(result).to be_present
            expect(result).to be_an_instance_of(Hash)
            expect(result[:success]).to be(true)
            expect(result[:logs]).to be_present
            expect(result[:logs]).to  be_an_instance_of(Array)
          end
        end

        context 'when the restaurant has extra valid attributes' do        
          subject { described_class.new(valid_restaurant_extra_attributes) }

          it 'returns an array of logs' do       
            expect(restaurant_double).to receive(:save).once   
            
            result = subject.call

            expect(result).to be_present
            expect(result).to be_an_instance_of(Hash)
            expect(result[:success]).to be(true)
            expect(result[:logs]).to be_present
            expect(result[:logs]).to  be_an_instance_of(Array)
          end
        end

        context 'When the restaurant is missing menus' do        
          subject { described_class.new(valid_restauran_missing_menus) }

          it 'creates the Restaurant' do    
            expect(restaurant_double).to receive(:save).once   
            expect(menu_double).not_to  receive(:save)
            expect(menu_item_double).not_to  receive(:save)       
            result = subject.call

            expect(result).to be_present
            expect(result).to be_an_instance_of(Hash)
            expect(result[:success]).to be(true)
            expect(result[:logs]).to be_present
            expect(result[:logs]).to  be_an_instance_of(Array)
          end
        end

        context 'When the menu is missing menu_items' do        
          subject { described_class.new(valid_menu_missing_items) }
          it 'creates the Restaurant and the Menu, but not a MenuItem' do
            expect(restaurant_double).to receive(:save).once   
            expect(menu_double).to receive(:save).once  
            expect(menu_item_double).not_to  receive(:save)        
            result = subject.call

            expect(result).to be_present
            expect(result).to be_an_instance_of(Hash)
            expect(result[:success]).to be(true)
            expect(result[:logs]).to be_present
            expect(result[:logs]).to  be_an_instance_of(Array)
          end
        end
      end
    end
  end
end