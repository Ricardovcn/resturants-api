require 'rails_helper'

RSpec.describe Api::V1::Restaurants::MenuItemMenusController, type: :controller do
  let(:restaurant_double) { instance_double(Restaurant) }
  let!(:menu) { create(:menu) }
  let!(:menu_item) { create(:menu_item) }
  let!(:menu_item_menu) { create(:menu_item_menu, menu_id: menu.id, menu_item_id: menu_item.id) }

  describe "POST /create" do
    context "gets an invalid restaurant id" do
      it 'returns a 200 code and the created menu_item_menus' do
        allow(Restaurant).to receive(:find_by_id).and_return(nil)
        
        post :create, params: { restaurant_id: 2, menu_id: 2, menu_item_id: 4 }

        expect(response).to have_http_status :not_found
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include("Restaurant ID not found. Please check that the restaurant exists in the system.")
      end
    end

    context "gets an invalid menu id" do
      it 'returns a 200 code and the created menu_item_menus' do
        allow(Restaurant).to receive(:find_by_id).and_return(restaurant_double)
        allow(restaurant_double).to receive_message_chain(:menus, :find_by_id).and_return(nil)
        
        post :create, params: { restaurant_id: 2, menu_id: 2, menu_item_id: 4 }

        expect(response).to have_http_status :not_found
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include("Menu ID not found for the given restaurant. Please verify the menu and restaurant IDs.")
      end
    end

    context "a required param is missing" do
      it 'returns a 200 code and the created menu_item_menus' do
        allow(Restaurant).to receive(:find_by_id).and_return(restaurant_double)
        allow(restaurant_double).to receive_message_chain(:menus, :find_by_id).and_return(menu)
        
        post :create, params: { restaurant_id: 2, menu_id: 2 }

        expect(response).to have_http_status :bad_request
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include("Required param missing")
      end
    end

    context "gets an invalid menu item id" do
      it 'returns a 200 code and the created menu_item_menus' do
        allow(Restaurant).to receive(:find_by_id).and_return(restaurant_double)
        allow(restaurant_double).to receive_message_chain(:menus, :find_by_id).and_return(menu)
        allow(restaurant_double).to receive_message_chain(:menu_items, :find_by_id).and_return(nil)

        post :create, params: { restaurant_id: 2, menu_id: 2, menu_item_id: 4 }

        expect(response).to have_http_status :not_found
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include("Menu item not found for the given restaurant. Please check the menu item and restaurant IDs.")
      end
    end

    context "gets valid parameters" do
      it 'returns a 200 code and the created menu_item_menus' do
        allow(Restaurant).to receive(:find_by_id).and_return(restaurant_double)
        allow(restaurant_double).to receive_message_chain(:menus, :find_by_id).and_return(menu)
        allow(restaurant_double).to receive_message_chain(:menu_items, :find_by_id).and_return(menu_item)
        allow(MenuItemMenu).to receive(:new).and_return(menu_item_menu)
        allow(menu_item_menu).to receive(:save).and_return(true)

        post :create, params: { restaurant_id: 2, menu_id: menu.id, menu_item_id: menu_item.id }
                
        expect(response).to have_http_status :ok
        json_response = JSON.parse(response.body)
        expect(json_response["menu_id"]).to eql(menu.id)
        expect(json_response["menu_item_id"]).to eql(menu_item.id)
      end
    end
  end

  describe "DELETE /destroy" do

    context "gets an invalid restaurant id" do
      it 'returns a 200 code and the created menu_item_menus' do
        allow(Restaurant).to receive(:find_by_id).and_return(nil)
        
        delete :destroy, params: { restaurant_id: 2, menu_id: 1, menu_item_id: 1}           

        expect(response).to have_http_status :not_found
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include("Restaurant ID not found. Please check that the restaurant exists in the system.")
      end
    end

    context "gets an invalid menu id" do
      it 'returns a 200 code and the created menu_item_menus' do
        allow(Restaurant).to receive(:find_by_id).and_return(restaurant_double)
        allow(restaurant_double).to receive_message_chain(:menus, :find_by_id).and_return(nil)
        
        delete :destroy, params: { restaurant_id: 2, menu_id: 1, menu_item_id: 1}           

        expect(response).to have_http_status :not_found
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include("Menu ID not found for the given restaurant. Please verify the menu and restaurant IDs.")
      end
    end

    context "gets an invalid menu item id" do
      it 'returns a 200 code and the created menu_item_menus' do
        allow(Restaurant).to receive(:find_by_id).and_return(restaurant_double)
        allow(restaurant_double).to receive_message_chain(:menus, :find_by_id).and_return(menu)
        allow(restaurant_double).to receive_message_chain(:menu_items, :find_by_id).and_return(nil)

        delete :destroy, params: { restaurant_id: 2, menu_id: 1, menu_item_id: 1}           

        expect(response).to have_http_status :not_found
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include("Menu item not found for the given restaurant. Please check the menu item and restaurant IDs.")
      end
    end

    context "gets valid parameters" do
      it 'returns a 204 code' do
        allow(Restaurant).to receive(:find_by_id).and_return(restaurant_double)
        allow(restaurant_double).to receive_message_chain(:menus, :find_by_id).and_return(menu)
        allow(restaurant_double).to receive_message_chain(:menu_items, :find_by_id).and_return(menu_item)
        allow(menu).to receive_message_chain(:menu_item_menus, :find_by).and_return(menu_item_menu)
                
        expect { 
          delete :destroy, params: { restaurant_id: 2, menu_id: 1, menu_item_id: 1}      
        }.to change { MenuItemMenu.count }.by(-1)
        
        expect(response).to have_http_status :no_content     
      end
    end
  end
end
