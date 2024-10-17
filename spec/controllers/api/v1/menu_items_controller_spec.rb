require 'rails_helper'

RSpec.describe Api::V1::MenuItemsController, type: :controller do
  let(:menu_item_name) { "Milkshake" }
  let(:duplicated_name) { "Mojito" }
  let(:too_big_name) { SecureRandom.hex(51) } 
  let(:too_big_description) { SecureRandom.hex(251) } 

  describe "GET /index" do
    it 'returns a 200 code and an array of menu items' do
      get :index
      
      expect(response).to have_http_status :ok
      json_response = JSON.parse(response.body)
      expect(json_response).to be_an_instance_of(Array)
      expect(json_response.size).to eql(MenuItem.all.size)
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

    context "gets a name that is already present in the database" do
      it 'returns a 400 code and an error message' do
        post :create, params: { name: "Mojito"}
        
        expect(response).to have_http_status :conflict
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to eql("A MenuItem with this name already exists.")
        expect(json_response["existing_object"]).to be_present
        expect(json_response["existing_object"]["id"]).to be_present
      end
    end

    context "gets a invalid name" do
      it 'returns a 409 code an an error message' do
        post :create, params: { name: too_big_name}

        expect(response).to have_http_status :unprocessable_entity
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include("Name is too long")
      end
    end

    context "gets a invalid description" do
      it 'returns a 409 code an an error message' do
        post :create, params: { name: menu_item_name, description: too_big_description}

        expect(response).to have_http_status :unprocessable_entity
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include("Description is too long")
      end
    end

    context "gets invalid calories" do
      it 'returns a 409 code an an error message' do
        post :create, params: { name: menu_item_name, calories: -1 }

        expect(response).to have_http_status :unprocessable_entity
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include("Calories must be greater than or equal to 0")
      end
    end

    context "gets invalid ingredients" do
      it 'returns a 409 code an an error message' do
        post :create, params: { name: menu_item_name, ingredients: [too_big_name, "ingredient2"] }

        expect(response).to have_http_status :unprocessable_entity
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include("Ingredients must be an array of strings with a maximum length of 100 characters")
      end
    end

    context "gets invalid allergens" do
      it 'returns a 409 code an an error message' do
        post :create, params: { name: menu_item_name, allergens: [too_big_name, "allergen2"] }

        expect(response).to have_http_status :unprocessable_entity
        json_response = JSON.parse(response.body)
        expect(json_response["message"]).to include("Allergens must be an array of strings with a maximum length of 100 characters")
      end
    end

    context "gets valid parameters" do
      it 'returns a 200 code and the created menu item' do
        post :create, params: { name: menu_item_name, menu_id: 1}

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
        json_response = JSON.parse(response.body)
        expect(json_response["id"]).to be(2)
        expect(json_response["name"]).to eql(menu_item_name)
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
        table_size_after_delete = MenuItem.all.size - 1
        delete :destroy, params: { id: 2}        

        expect(response).to have_http_status :no_content
        expect(MenuItem.all.size).to eql(table_size_after_delete)
      end
    end
  end
end
