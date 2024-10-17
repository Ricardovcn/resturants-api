require 'rails_helper'

RSpec.describe Api::V1::RestaurantsController, type: :controller do
  let(:new_restaurant_name) { "New Restaurant Name" }
  let(:too_big_name) { SecureRandom.hex(51) } 
  let(:too_big_description) { SecureRandom.hex(251) } 

  describe "GET /index" do
    it 'returns a 200 code and an array of restaurants' do
      get :index

      expect(response).to have_http_status :ok
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an_instance_of(Array)
      expect(json_response.size).to eql(Restaurant.all.size)
    end
  end

  describe "GET /show" do
    context "gets an invalid ID as parameter" do
      it 'returns a 404 code and an error message' do
        get :show, params: { id: 5}
        
        expect(response).to have_http_status :not_found
        expect(JSON.parse(response.body)["message"]).to eql("Invalid restaurant id!")
      end
    end

    context "gets a valid ID as parameter" do
      it 'returns a 200 code and the requested restaurant' do
        get :show, params: { id: 1}

        expect(response).to have_http_status :ok
        expect(JSON.parse(response.body)["id"]).to be(1)
      end
    end
  end

  describe "POST /create" do
    context "one of the required parameters is missing" do
      it 'returns a 400 code and an error message' do
        post :create, params: { description: "description"}
        
        expect(response).to have_http_status :bad_request
        expect(JSON.parse(response.body)["message"]).to include("Required param missing")
      end
    end

    context "gets no parameter" do
      it 'returns a 400 code and an error message' do
        post :create, params: {}
        
        expect(response).to have_http_status :bad_request
        expect(JSON.parse(response.body)["message"]).to eql("No restaurant attributes was passed as parameters.")
      end
    end

    context "gets a invalid name" do
      it 'returns a 200 code and the created restaurant' do
        post :create, params: { name: too_big_name, restaurant_id: 1}

        expect(response).to have_http_status :unprocessable_entity
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include("Name is too long")
      end
    end

    context "gets a invalid description" do
      it 'returns a 200 code and the created restaurant' do
        post :create, params: { name: new_restaurant_name, description: too_big_description, restaurant_id: 1}

        expect(response).to have_http_status :unprocessable_entity
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include("Description is too long")
      end
    end

    context "gets an invalid email" do
      it 'returns a 200 code and the created restaurant' do
        post :create, params: { name: new_restaurant_name, restaurant_id: 1, email: "invalid"}

        expect(response).to have_http_status :unprocessable_entity
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include("Email is invalid")
      end
    end

    context "gets an invalid phone number" do
      it 'returns a 200 code and the created restaurant' do
        post :create, params: { name: new_restaurant_name, restaurant_id: 1, phone_number: "invalid"}

        expect(response).to have_http_status :unprocessable_entity
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include("Phone number must be a valid phone number")
      end
    end

    context "gets valid parameters" do
      it 'returns a 200 code and the created restaurant' do
        post :create, params: { name: "Restaurant Name 3", restaurant_id: 1}

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
        put :update, params: { id: 10, name: "New Restaurant Name"}

        expect(response).to have_http_status :not_found
        expect(JSON.parse(response.body)["message"]).to eql("Invalid restaurant id!")
      end
    end

    context "gets no parameters" do
      it 'returns a 400 code and an error message' do
        put :update, params: { id: 2 }

        expect(response).to have_http_status :bad_request
        expect(JSON.parse(response.body)["message"]).to eql("No restaurant attributes was passed as parameters.")
      end
    end

    context "gets valid parameters" do
      it 'returns a 200 code and the updated restaurant' do
        put :update, params: { id: 2, name: new_restaurant_name}
        
        expect(response).to have_http_status :ok
        json_response = JSON.parse(response.body)
        expect(json_response["id"]).to be(2)
        expect(json_response["name"]).to eql(new_restaurant_name)
      end
    end
  end

  describe "DELETE /destroy" do
    context "gets an invalid ID as parameter" do
      it 'returns a 400 code and an error message' do
        delete :destroy, params: { id: 99}
        
        expect(response).to have_http_status :not_found
        expect(JSON.parse(response.body)["message"]).to eql("Invalid restaurant id!")
      end
    end

    context "gets a valid ID as parameter" do
      it 'returns a 204 code' do
        table_size_after_delete = Restaurant.all.size - 1
        delete :destroy, params: { id: 2}        

        expect(response).to have_http_status :no_content
        expect(Restaurant.all.size).to eql(table_size_after_delete)
      end
    end
  end

  describe "GET /menus" do
    context "gets an invalid restaurant ID as parameter" do
      it 'returns a 400 code and an error message' do
        get :menus, params: { id: 99}
        
        expect(response).to have_http_status :not_found
        expect(JSON.parse(response.body)["message"]).to eql("Invalid restaurant id!")
      end
    end

    context "gets a valid restaurant ID as parameter" do
      it 'returns a 200 code and an array of menus' do
        get :menus, params: { id: 2}        

        expect(response).to have_http_status :ok
        json_response = JSON.parse(response.body)
        expect(json_response).to be_an_instance_of(Array)
        expect(json_response.size).to eql(Restaurant.find_by(id: 2).menus.size)
      end
    end
  end
end
