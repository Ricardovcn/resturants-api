class Api::V1::Restaurants::MenuItemMenusController < ApplicationController
  before_action :set_restaurant, :set_menu
  before_action :required_params, only: [:create]
  before_action :set_menu_item_menu, only: [:destroy]

  REQUIRED_PARAMS = [
    "menu_item_id"
  ].freeze

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
    @menu_item_menu = @menu.menu_item_menus.find_by(menu_item_id: params["menu_item_id"])
    render_error("Invalid ID's!", :not_found) if @menu_item_menu.nil?
  end

  def set_menu
    @menu =  @restaurant.menus.find_by_id(params['menu_id'])
    render_error("Invalid menu id!", :not_found) if @menu.nil?
  end

  def set_restaurant   
    @restaurant = Restaurant.find_by_id(params['restaurant_id'])
    render_error("Invalid restaurant id!", :not_found) if @restaurant.nil?
  end
end
