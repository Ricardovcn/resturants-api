require 'rails_helper'

RSpec.describe Api::V1::MenuItemMenusController, type: :controller do
  describe "GET /index" do
    it 'returns a 200 code and an array of menu_item_menus' do
      get :index

      expect(response).to have_http_status :ok
      expect(JSON.parse(response.body)).to be_an_instance_of(Array)
      expect(JSON.parse(response.body).size).to eql(MenuItemMenu.all.size)
    end
  end

  describe "POST /create" do
    context "one of the required parameters is missing" do
      it 'returns a 400 code and an error message' do
        post :create, params: {}
        
        expect(response).to have_http_status :bad_request
        expect(JSON.parse(response.body)["message"]).to include("Required param missing")
      end
    end

    context "gets valid parameters" do
      it 'returns a 200 code and the created menu_item_menus' do
        post :create, params: { menu_id: 1, menu_item_id: 1}

        expect(response).to have_http_status :ok
        expect(JSON.parse(response.body)["menu_id"]).to be_present
        expect(JSON.parse(response.body)["menu_item_id"]).to be_present
      end
    end
  end

  describe "DELETE /destroy" do
    context "one of the required parameters is missing" do
      it 'returns a 400 code and an error message' do
        delete :destroy, params: {}
        
        expect(response).to have_http_status :bad_request
        expect(JSON.parse(response.body)["message"]).to include("Required param missing")
      end
    end

    context "gets valid parameters" do
      it 'returns a 204 code' do
        table_size_after_delete = MenuItemMenu.all.size - 1
        delete :destroy, params: { menu_id: 1, menu_item_id: 1}   

        expect(response).to have_http_status :no_content
        expect(MenuItemMenu.all.size).to eql(table_size_after_delete)
      end
    end
  end
end
