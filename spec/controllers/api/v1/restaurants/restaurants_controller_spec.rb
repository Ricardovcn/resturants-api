require 'rails_helper'

RSpec.describe Api::V1::Restaurants::RestaurantsController, type: :controller do
  let(:new_restaurant_name) { "New Restaurant Name" }
  let(:too_big_name) { SecureRandom.hex(51) }
  let(:too_big_description) { SecureRandom.hex(251) }
  let!(:restaurants) { create_list(:restaurant, 5) }
  let(:error_message) { "error_message" }
  let(:restaurant_double) { instance_double(Restaurant)}

  describe "GET /index" do
    it 'returns a 200 code and an array of restaurants' do
      allow(Restaurant).to receive_message_chain(:page, :per).and_return(restaurants)

      get :index
            
      expect(response).to have_http_status :ok
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an_instance_of(Array)
      expect(json_response.size).to eql(restaurants.size)
    end
  end

  describe "GET /show" do
    context "gets an invalid ID as parameter" do
      it 'returns a 404 code and an error message' do
        allow(Restaurant).to receive(:find_by_id).with("5").and_return(nil)

        get :show, params: { id: 5}
        
        expect(response).to have_http_status :not_found
        expect(JSON.parse(response.body)["message"]).to eql("Restaurant ID not found. Please check that the restaurant exists in the system.")
      end
    end

    context "gets a valid ID as parameter" do
      it 'returns a 200 code and the requested restaurant' do
        allow(Restaurant).to receive(:find_by_id).with(restaurants.first.id.to_s).and_return(restaurants.first)

        get :show, params: { id: restaurants.first.id}

        expect(response).to have_http_status :ok
        expect(JSON.parse(response.body)["id"]).to eql(restaurants.first.id)
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

    context "gets a error while saving" do
      it 'returns a 422 code an error message' do
        allow(Restaurant).to receive(:new).and_return(restaurant_double)
        allow(restaurant_double).to receive(:save).and_return(false)
        allow(restaurant_double).to receive_message_chain(:errors, :full_messages).and_return([error_message])
        post :create, params: { name: too_big_name}

        expect(response).to have_http_status :unprocessable_entity
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include(error_message)
      end
    end

    context "gets valid parameters" do
      it 'returns a 200 code and the created restaurant' do
        allow(Restaurant).to receive(:new).and_return(restaurants.first)
        allow(restaurants.first).to receive(:save).and_return(true)
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
        allow(Restaurant).to receive(:find_by_id).with("10").and_return(nil)

        put :update, params: { id: 10, name: "New Restaurant Name"}

        expect(response).to have_http_status :not_found
        expect(JSON.parse(response.body)["message"]).to eql("Restaurant ID not found. Please check that the restaurant exists in the system.")
      end
    end

    context "gets no parameters" do
      it 'returns a 400 code and an error message' do
        put :update, params: { id: 2 }

        expect(response).to have_http_status :bad_request
        expect(JSON.parse(response.body)["message"]).to eql("No restaurant attributes was passed as parameters.")
      end
    end

    context "gets an error while updating" do
      it 'returns a 200 code and the updated restaurant' do
        allow(Restaurant).to receive(:find_by_id).and_return(restaurant_double)
        allow(restaurant_double).to receive(:update).and_return(false)
        allow(restaurant_double).to receive_message_chain(:errors, :full_messages).and_return([error_message])
        put :update, params: { id: 2, name: new_restaurant_name}
        
        expect(response).to have_http_status :unprocessable_entity
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include(error_message)
      end
    end

    context "gets valid parameters" do
      it 'returns a 200 code and the updated restaurant' do
        allow(Restaurant).to receive(:find_by_id).with(restaurants.first.id.to_s).and_return(restaurants.first)
        allow(restaurants.first).to receive(:update).and_return(true)
        put :update, params: { id: restaurants.first.id, name: new_restaurant_name}
        
        expect(response).to have_http_status :ok
        json_response = JSON.parse(response.body)
        expect(json_response["id"]).to eql(restaurants.first.id)
        expect(json_response["name"]).to eql(restaurants.first.name)
      end
    end
  end

  describe "DELETE /destroy" do
    context "gets an invalid ID as parameter" do
      it 'returns a 400 code and an error message' do
        allow(Restaurant).to receive(:find_by_id).with(restaurants.first.id.to_s).and_return(nil)
        delete :destroy, params: { id: restaurants.first.id}
        
        expect(response).to have_http_status :not_found
        expect(JSON.parse(response.body)["message"]).to eql("Restaurant ID not found. Please check that the restaurant exists in the system.")
      end
    end

    context "gets a valid ID as parameter" do
      it 'returns a 204 code' do
        allow(Restaurant).to receive(:find_by_id).with(restaurants.first.id.to_s).and_return(restaurants.first)
        expect { 
          delete :destroy, params: { id: restaurants.first.id} 
        }.to change { Restaurant.count }.by(-1)
                
        expect(response).to have_http_status :no_content
      end
    end
  end
end
