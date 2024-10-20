require 'rails_helper'

RSpec.describe Api::V1::Restaurants::MenusController, type: :controller do
  let(:new_menu_name) { "New Menu Name" }
  let(:too_big_name) { SecureRandom.hex(51) } 
  let(:too_big_description) { SecureRandom.hex(251) } 

  describe "GET /index" do
    it 'returns a 200 code and an array of menus' do
      get :index, params: { id: 5, restaurant_id: 1}

      expect(response).to have_http_status :ok
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an_instance_of(Array)
      expect(json_response.size).to eql(Menu.where(restaurant_id: 1).size)
    end
  end

  describe "GET /show" do
    context "gets an invalid ID as parameter" do
      it 'returns a 404 code and an error message' do
        get :show, params: { id: 5,  restaurant_id: 1}
        
        expect(response).to have_http_status :not_found
        expect(JSON.parse(response.body)["message"]).to eql("Menu ID not found for the given restaurant. Please verify the menu and restaurant IDs.!")
      end
    end

    context "gets a valid ID as parameter" do
      it 'returns a 200 code and the requested menu' do
        get :show, params: { id: 1, restaurant_id: 2}

        expect(response).to have_http_status :ok
        expect(JSON.parse(response.body)["id"]).to be(1)
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

    context "gets a invalid name" do
      it 'returns a 409 code an an error message' do
        post :create, params: { name: too_big_name, restaurant_id: 1}

        expect(response).to have_http_status :unprocessable_entity
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include("Name is too long")
      end
    end

    context "gets a invalid description" do
      it 'returns a 409 code an an error message' do
        post :create, params: { name: new_menu_name, description: too_big_description, restaurant_id: 1}

        expect(response).to have_http_status :unprocessable_entity
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include("Description is too long")
      end
    end

    context "gets valid parameters" do
      it 'returns a 200 code and the created menu' do
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
        put :update, params: { id: 10, name: "New Menu Name", restaurant_id: 1}

        expect(response).to have_http_status :not_found
        expect(JSON.parse(response.body)["message"]).to eql("Menu ID not found for the given restaurant. Please verify the menu and restaurant IDs.!")
      end
    end

    context "gets no update parameters" do
      it 'returns a 400 code and an error message' do
        put :update, params: { id: 1, restaurant_id: 2 }

        expect(response).to have_http_status :bad_request
        expect(JSON.parse(response.body)["message"]).to eql("No menu attributes was passed as parameters.")
      end
    end

    context "gets valid parameters" do
      it 'returns a 200 code and the updated menu' do
        put :update, params: { id: 1, name: new_menu_name, restaurant_id: 2 }
        
        expect(response).to have_http_status :ok
        json_response = JSON.parse(response.body) 
        expect(json_response["id"]).to be(1)
        expect(json_response["name"]).to eql(new_menu_name)
      end
    end
  end

  describe "DELETE /destroy" do
    context "gets an invalid ID as parameter" do
      it 'returns a 400 code and an error message' do
        delete :destroy, params: { id: 99, restaurant_id: 1 }
        
        expect(response).to have_http_status :not_found
        expect(JSON.parse(response.body)["message"]).to eql("Menu ID not found for the given restaurant. Please verify the menu and restaurant IDs.!")
      end
    end

    context "gets a valid ID as parameter" do
      it 'returns a 204 code' do
        table_size_after_delete = Menu.all.size - 1
        delete :destroy, params: { id: 1, restaurant_id: 2 }        

        expect(response).to have_http_status :no_content
        expect(Menu.all.size).to eql(table_size_after_delete)
      end
    end
  end
end
