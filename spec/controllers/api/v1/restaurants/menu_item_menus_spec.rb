require 'rails_helper'

RSpec.describe Api::V1::Restaurants::MenuItemMenusController, type: :controller do
  describe "POST /create" do
    context "gets valid parameters" do
      it 'returns a 200 code and the created menu_item_menus' do
        post :create, params: { restaurant_id: 2, menu_id: 1, menu_item_id: 2 }

        expect(response).to have_http_status :ok
        json_response = JSON.parse(response.body)
        expect(json_response["menu_id"]).to be_present
        expect(json_response["menu_item_id"]).to be_present
      end
    end
  end

  describe "DELETE /destroy" do
    context "gets valid parameters" do
      it 'returns a 204 code' do
        table_size_after_delete = MenuItemMenu.all.size - 1
        delete :destroy, params: { restaurant_id: 2, menu_id: 1, menu_item_id: 1}   

        expect(response).to have_http_status :no_content
        expect(MenuItemMenu.all.size).to eql(table_size_after_delete)
      end
    end
  end
end
