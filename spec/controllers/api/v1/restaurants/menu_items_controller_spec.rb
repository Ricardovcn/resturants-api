require 'rails_helper'

RSpec.describe Api::V1::Restaurants::MenuItemsController, type: :controller do
  let(:menu_item_name) { "Milkshake" }
  let(:duplicated_name) { "Mojito" }
  let(:too_big_name) { SecureRandom.hex(51) } 
  let(:too_big_description) { SecureRandom.hex(251) } 
  let(:restaurant_model) {  Restaurant.find(2) }
  let!(:restaurant) { create(:restaurant) }
  let!(:restaurant_double) { instance_double(Restaurant) }
  let(:menu_items) { [create(:menu_item, name: "Unique Name 1", price_in_cents: 1500), create(:menu_item, name: "Unique Name 2")] }
  let(:error_message) { "error_message" }

  before do
    allow(Restaurant).to receive(:find_by_id).and_return(restaurant_double)
  end

  describe "GET /index" do
    it 'returns a 200 code and an array of menu items' do
      allow(restaurant_double).to receive(:menu_items).and_return(menu_items)

      get :index, params: { restaurant_id: restaurant_model.id}
      
      expect(response).to have_http_status :ok
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an_instance_of(Array)
      expect(json_response.size).to eql(menu_items.size)
    end
  end

  describe "GET /show" do
    context "gets an invalid ID as parameter" do
      it 'returns a 404 code and an error message' do
        allow(restaurant_double).to receive_message_chain(:menu_items, :find_by_id).and_return(nil)

        get :show, params: { restaurant_id: restaurant_model.id, id: 20}
        
        expect(response).to have_http_status :not_found
        expect(JSON.parse(response.body)["message"]).to eql("Menu item not found for the given restaurant. Please check the menu item and restaurant IDs.")
      end
    end

    context "gets a valid ID as parameter" do
      it 'returns a 200 code and the requested menu item' do
        allow(restaurant_double).to receive_message_chain(:menu_items, :find_by_id).and_return(menu_items.first)

        get :show, params: { restaurant_id: restaurant_model.id, id: menu_items.first.id}

        expect(response).to have_http_status :ok
        expect(JSON.parse(response.body)["id"]).to eql(menu_items.first.id)
      end
    end
  end

  describe "POST /create" do
    context "one of the required parameters is missing" do
      it 'returns a 400 code and an error message' do
        post :create, params: { restaurant_id: restaurant_model.id, description: "description"}
        
        expect(response).to have_http_status :bad_request
        expect(JSON.parse(response.body)["message"]).to include("Required param missing")
      end
    end

    context "gets an error while saving" do
      it 'returns a 422 code and an error message' do
        allow(MenuItem).to receive(:new).and_return(menu_items.first)
        allow(menu_items.first).to receive(:save).and_return(false)
        allow(menu_items.first).to receive_message_chain(:errors, :full_messages).and_return([error_message])
        allow(restaurant_double).to receive_message_chain(:menu_items, :find_by_name).and_return(nil)

        post :create, params: { restaurant_id: restaurant_model.id, name: "Mojito"}
        
        expect(response).to have_http_status :unprocessable_entity
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include(error_message)
      end
    end

    context "the menu item anem already exists for the restaurant" do
      it 'returns a 409 code and an existing object' do
        allow(menu_items.first).to receive(:save).and_return(false)
        allow(menu_items.first).to receive_message_chain(:errors, :full_messages).and_return([error_message])
        allow(restaurant_double).to receive_message_chain(:menu_items, :find_by_name).and_return(menu_items.first)

        post :create, params: { restaurant_id: restaurant_model.id, name: "Mojito"}
        
        expect(response).to have_http_status :conflict
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include("A MenuItem with this name already exists.")
        expect(json_response["existing_object"]).to eql(menu_items.first.as_json)
      end
    end

    context "gets valid parameters" do
      it 'returns a 200 code and the created menu item' do
        allow(MenuItem).to receive(:new).and_return(menu_items.first)
        allow(menu_items.first).to receive(:update).and_return(true)
        allow(restaurant_double).to receive_message_chain(:menu_items, :find_by_name).and_return(nil)

        post :create, params: { name: menu_item_name, menu_id: 1, restaurant_id: restaurant_model.id}

        expect(response).to have_http_status :ok
        json_response = JSON.parse(response.body)
        expect(json_response["id"]).to be_present
        expect(json_response["name"]).to be_present
      end
    end
  end

  describe "PUT /update" do
    context "gets an invalid ID as parameter" do
      it 'returns a 404 code and an error message' do
        allow(restaurant_double).to receive_message_chain(:menu_items, :find_by_id).and_return(nil)

        put :update, params: { id: 10, name: "New Menu Item Name", restaurant_id: 1}

        expect(response).to have_http_status :not_found
        expect(JSON.parse(response.body)["message"]).to eql("Menu item not found for the given restaurant. Please check the menu item and restaurant IDs.")
      end
    end

    context "gets no update parameters" do
      it 'returns a 400 code and an error message' do
        allow(restaurant_double).to receive_message_chain(:menu_items, :find_by_id).and_return(menu_items.first)
        
        put :update, params: { id: menu_items.first.id, restaurant_id: restaurant.id }

        expect(response).to have_http_status :bad_request
        expect(JSON.parse(response.body)["message"]).to eql("No menu item attributes was passed as parameters.")
      end
    end

    context "gets an error while updating" do
      it 'returns a 422 code and error message' do
        allow(restaurant_double).to receive_message_chain(:menu_items, :find_by_id).and_return(menu_items.first)
        allow(menu_items.first).to receive(:update).and_return(false)
        allow(menu_items.first).to receive_message_chain(:errors, :full_messages).and_return([error_message])
        allow(restaurant_double).to receive_message_chain(:menu_items, :find_by_name).and_return(nil)

        put :update, params: { id: menu_items.first.id, name: menu_item_name, restaurant_id: restaurant.id }
        
        expect(response).to have_http_status :unprocessable_entity
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include(error_message)
      end
    end

    context "the menu item anem already exists for the restaurant" do
      it 'returns a 409 code and error an existing object' do
        allow(restaurant_double).to receive_message_chain(:menu_items, :find_by_id).and_return(menu_items.first)
        allow(menu_items.first).to receive(:save).and_return(false)
        allow(menu_items.first).to receive_message_chain(:errors, :full_messages).and_return([error_message])
        allow(restaurant_double).to receive_message_chain(:menu_items, :find_by_name).and_return(menu_items.first)

        put :update, params: { id: menu_items.first.id, name: menu_item_name, restaurant_id: restaurant.id }
        
        expect(response).to have_http_status :conflict
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include("A MenuItem with this name already exists.")
        expect(json_response["existing_object"]).to eql(menu_items.first.as_json)
      end
    end

    context "gets valid parameters" do
      it 'returns a 200 code and the updated menu item' do
        allow(restaurant_double).to receive_message_chain(:menu_items, :find_by_id).and_return(menu_items.first)
        allow(menu_items.first).to receive(:update).and_return(true)
        allow(restaurant_double).to receive_message_chain(:menu_items, :find_by_name).and_return(nil)

        put :update, params: { id: menu_items.first.id, name: menu_item_name, restaurant_id: restaurant.id }
        
        expect(response).to have_http_status :ok
        json_response = JSON.parse(response.body) 
        expect(json_response["id"]).to eql(menu_items.first.id)
      end
    end
  end

  describe "DELETE /destroy" do
    context "gets an invalid ID as parameter" do
      it 'returns a 400 code and an error message' do
        allow(restaurant_double).to receive_message_chain(:menu_items, :find_by_id).and_return(nil)

        delete :destroy, params: { id: 99, restaurant_id: 1 }
        
        expect(response).to have_http_status :not_found
        expect(JSON.parse(response.body)["message"]).to eql("Menu item not found for the given restaurant. Please check the menu item and restaurant IDs.")
      end
    end

    context "gets a valid ID as parameter" do
      it 'returns a 204 code' do
        allow(restaurant_double).to receive_message_chain(:menu_items, :find_by_id).and_return(menu_items.first)
        
        expect { 
          delete :destroy, params: { id: menu_items.first.id, restaurant_id: 2} 
        }.to change { MenuItem.count }.by(-1)

        expect(response).to have_http_status :no_content
      end
    end
  end
end
