class Api::V1::Restaurants::MenusController < ApplicationController
  before_action :set_restaurant
  before_action :set_menu, only: [:show, :update, :destroy, :menu_items]
  before_action :validate_empty_body, only: [:update]
  before_action :required_params, only: :create

  REQUIRED_PARAMS = [
    "name",
    "restaurant_id"
  ].freeze
  
  def index
    render json: @restaurant.menus, include: :menu_items
  end

  def show
    render json: @menu, include: :menu_items
  end

  def create
    @menu = Menu.new(permitted_params)

    if @menu.save
      render json: @menu
    else      
      render_error(@menu.errors.full_messages.join(", "), :unprocessable_entity)
    end
  end

  def update
    if @menu.update(permitted_params)
      render json: @menu
    else
      render_error(@menu.errors.full_messages.join(", "), :unprocessable_entity)
    end
  end

  def destroy
    @menu.destroy

    head :no_content
  end

  private 

  def validate_empty_body    
    render_error("No menu attributes was passed as parameters.", :bad_request) if permitted_params.to_h.except("restaurant_id").blank?
  end

  def required_params
    REQUIRED_PARAMS.each do |param|
      return render_error("Required param missing: #{param}", :bad_request) unless params[param]
    end
  end

  def permitted_params
    params.permit(:name, :description, :is_active, :restaurant_id)
  end

  def set_menu
    @menu =  @restaurant.menus.find_by_id(params['id'])
    render_error("Menu ID not found for the given restaurant. Please verify the menu and restaurant IDs.", :not_found) if @menu.nil?
  end

  def set_restaurant   
    @restaurant = Restaurant.find_by_id(params['restaurant_id'])
    render_error("Restaurant ID not found. Please check that the restaurant exists in the system.", :not_found) if @restaurant.nil?
  end
end
