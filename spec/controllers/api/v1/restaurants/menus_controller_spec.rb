require 'rails_helper'

RSpec.describe Api::V1::Restaurants::MenusController, type: :controller do
  let(:new_menu_name) { "New Menu Name" }
  let(:too_big_name) { SecureRandom.hex(51) } 
  let(:too_big_description) { SecureRandom.hex(251) } 
  let!(:restaurant) { create(:restaurant) }
  let!(:restaurant_double) { instance_double(Restaurant) }
  let(:menus) {create_list(:menu, 3, restaurant: restaurant)}
  let(:error_message) { "error_message" }

  before do
    allow(Restaurant).to receive(:find_by_id).and_return(restaurant_double)
  end
 
  describe "GET /index" do
    it 'returns a 200 code and an array of menus' do
      allow(restaurant_double).to receive(:menus).and_return(menus)

      get :index, params: { restaurant_id: restaurant.id }

      expect(response).to have_http_status :ok
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an_instance_of(Array)
      expect(json_response.size).to eql(menus.size)
    end
  end

  describe "GET /show" do
    context "gets an invalid ID as parameter" do
      it 'returns a 404 code and an error message' do
        allow(restaurant_double).to receive_message_chain(:menus, :find_by_id).and_return(nil)

        get :show, params: { id: 20,  restaurant_id: restaurant.id}
        
        expect(response).to have_http_status :not_found
        expect(JSON.parse(response.body)["message"]).to eql("Menu ID not found for the given restaurant. Please verify the menu and restaurant IDs.")
      end
    end

    context "gets a valid ID as parameter" do
      it 'returns a 200 code and the requested menu' do
        allow(restaurant_double).to receive_message_chain(:menus, :find_by_id).and_return(menus.first)
        get :show, params: { id: menus.first.id, restaurant_id: 2}

        expect(response).to have_http_status :ok
        expect(JSON.parse(response.body)["id"]).to eql(menus.first.id)
      end
    end
  end

  describe "POST /create" do
    context "one of the required parameters is missing" do
      it 'returns a 400 code and an error message' do
        post :create, params: { description: "description", restaurant_id: 1}
        
        expect(response).to have_http_status :bad_request
        expect(JSON.parse(response.body)["message"]).to include("Required param missing")
      end
    end

    context "gets an error while saving" do
      it 'returns a 422 code an an error message' do
        allow(Menu).to receive(:new).and_return(menus.first)
        allow(menus.first).to receive(:save).and_return(false)
        allow(menus.first).to receive_message_chain(:errors, :full_messages).and_return([error_message])

        post :create, params: { name: too_big_name, restaurant_id: 1}

        expect(response).to have_http_status :unprocessable_entity
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include(error_message)
      end
    end

    context "gets valid parameters" do
      it 'returns a 200 code and the created menu' do
        allow(Menu).to receive(:new).and_return(menus.first)
        allow(menus.first).to receive(:update).and_return(true)
        
        post :create, params: { name: "Menu Name 3", restaurant_id: 1}

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
        allow(restaurant_double).to receive_message_chain(:menus, :find_by_id).and_return(nil)

        put :update, params: { id: 10, name: "New Menu Name", restaurant_id: 1}

        expect(response).to have_http_status :not_found
        expect(JSON.parse(response.body)["message"]).to eql("Menu ID not found for the given restaurant. Please verify the menu and restaurant IDs.")
      end
    end

    context "gets no update parameters" do
      it 'returns a 400 code and an error message' do
        allow(restaurant_double).to receive_message_chain(:menus, :find_by_id).and_return(menus.first)
        
        put :update, params: { id: menus.first.id, restaurant_id: restaurant.id }

        expect(response).to have_http_status :bad_request
        expect(JSON.parse(response.body)["message"]).to eql("No menu attributes was passed as parameters.")
      end
    end

    context "gets an error while updating" do
      it 'returns a 422 code and error message' do
        allow(restaurant_double).to receive_message_chain(:menus, :find_by_id).and_return(menus.first)
        allow(menus.first).to receive(:update).and_return(false)
        allow(menus.first).to receive_message_chain(:errors, :full_messages).and_return([error_message])

        put :update, params: { id: menus.first.id, name: new_menu_name, restaurant_id: restaurant.id }
        
        expect(response).to have_http_status :unprocessable_entity
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include(error_message)
      end
    end

    context "gets valid parameters" do
      it 'returns a 200 code and the updated menu' do
        allow(restaurant_double).to receive_message_chain(:menus, :find_by_id).and_return(menus.first)
        allow(menus.first).to receive(:update).and_return(true)

        put :update, params: { id: menus.first.id, name: new_menu_name, restaurant_id: restaurant.id }
        
        expect(response).to have_http_status :ok
        json_response = JSON.parse(response.body) 
        expect(json_response["id"]).to eql(menus.first.id)
      end
    end
  end

  describe "DELETE /destroy" do
    context "gets an invalid ID as parameter" do
      it 'returns a 400 code and an error message' do
        allow(restaurant_double).to receive_message_chain(:menus, :find_by_id).and_return(nil)

        delete :destroy, params: { id: 99, restaurant_id: 1 }
        
        expect(response).to have_http_status :not_found
        expect(JSON.parse(response.body)["message"]).to eql("Menu ID not found for the given restaurant. Please verify the menu and restaurant IDs.")
      end
    end

    context "gets a valid ID as parameter" do
      it 'returns a 204 code' do
        allow(restaurant_double).to receive_message_chain(:menus, :find_by_id).and_return(menus.first)
        
        expect { 
          delete :destroy, params: { id: menus.first.id, restaurant_id: 2} 
        }.to change { Menu.count }.by(-1)

        expect(response).to have_http_status :no_content
      end
    end
  end
end
