require 'rails_helper'

RSpec.describe Api::V1::MenuItemsController, type: :controller do
  let(:menu_item_name) { "Milkshake" }

  describe "GET /index" do
    it 'returns a 200 code and an array of menu items' do
      get :index
      
      expect(response).to have_http_status :ok
      expect(JSON.parse(response.body)).to be_an_instance_of(Array)
      expect(JSON.parse(response.body).size).to eql(MenuItem.all.size)
    end
  end

  describe "GET /show" do
    context "gets an invalid ID as parameter" do
      it 'returns a 404 code and an error message' do
        get :show, params: { id: 20}
        
        expect(response).to have_http_status :not_found
        expect(JSON.parse(response.body)["message"]).to eql("Invalid menu item id!")
      end
    end

    context "gets a valid ID as parameter" do
      it 'returns a 200 code and the requested menu item' do
        get :show, params: { id: 1}

        expect(response).to have_http_status :ok
        expect(JSON.parse(response.body)["id"]).to be(1)
      end
    end
  end

  describe "POST /create" do
    context "gets no parameter" do
      it 'returns a 400 code and an error message' do
        post :create, params: {}
        
        expect(response).to have_http_status :bad_request
        expect(JSON.parse(response.body)["message"]).to eql("No menu item attributes was passed as parameters.")
      end
    end

    context "one of the required parameters is missing" do
      it 'returns a 400 code and an error message' do
        post :create, params: { description: "description"}
        
        expect(response).to have_http_status :bad_request
        expect(JSON.parse(response.body)["message"]).to include("Required param missing")
      end
    end

    context "gets valid parameters" do
      it 'returns a 200 code and the created menu item' do
        post :create, params: { name: menu_item_name, menu_id: 1}

        expect(response).to have_http_status :ok
        expect(JSON.parse(response.body)["id"]).to be_present
        expect(JSON.parse(response.body)["name"]).to be_present
      end
    end
  end

  describe "PUT /update" do
    context "gets an invalid ID as parameter" do
      it 'returns a 404 code and an error message' do
        put :update, params: { id: 20, name: menu_item_name}

        expect(response).to have_http_status :not_found
        expect(JSON.parse(response.body)["message"]).to eql("Invalid menu item id!")
      end
    end

    context "gets no parameters" do
      it 'returns a 400 code and an error message' do
        put :update, params: { id: 2 }

        expect(response).to have_http_status :bad_request
        expect(JSON.parse(response.body)["message"]).to eql("No menu item attributes was passed as parameters.")
      end
    end

    context "gets valid parameters" do
      it 'returns a 200 code and the updated menu item' do
        put :update, params: { id: 2, name: menu_item_name}
        
        expect(response).to have_http_status :ok
        expect(JSON.parse(response.body)["id"]).to be(2)
        expect(JSON.parse(response.body)["name"]).to eql(menu_item_name)
      end
    end
  end

  describe "DELETE /destroy" do
    context "gets an invalid ID as parameter" do
      it 'returns a 400 code and an error message' do
        delete :destroy, params: { id: 99}
        
        expect(response).to have_http_status :not_found
        expect(JSON.parse(response.body)["message"]).to eql("Invalid menu item id!")
      end
    end

    context "gets a valid ID as parameter" do
      it 'returns a 204 code' do
        delete :destroy, params: { id: 2}        

        expect(response).to have_http_status :no_content
      end
    end
  end
end
