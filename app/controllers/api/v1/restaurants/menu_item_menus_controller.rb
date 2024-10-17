class Api::V1::Restaurants::MenuItemMenusController < ApplicationController
    before_action :required_params, only: [:create, :destroy]
    before_action :set_menu_item_menu  

    REQUIRED_PARAMS = [
      "menu_id",
      "menu_item_id"
    ].freeze
    
    def index
      render json: MenuItemMenu.all
    end
  
    def create
      @menu_item_menu = MenuItemMenu.new(permitted_params)

      if @menu_item_menu.save
        render json: @menu_item_menu
      else
        render_error(@menu_item_menu.errors.full_messages.join(", "), :unprocessable_entity)
      end
    end
  
    def destroy
      @menu_item_menu.destroy

      head :no_content
    end

    private 

    def required_params
      REQUIRED_PARAMS.each do |param|
        return render_error("Required param missing: #{param}", :bad_request) unless params[param]
      end
    end
  
    def permitted_params
      params.permit(:menu_id, :menu_item_id)
    end
  
    def set_menu_item_menu
      @menu_item_menu = MenuItemMenu.find_by(permitted_params)
      render_error("Invalid ID's!", :not_found) if @menu_item_menu.nil?
    end
end
