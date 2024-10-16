class Api::V1::MenuItemsController < ApplicationController
  before_action :set_menu_item, only: [:show, :update, :destroy]
  before_action :validate_empty_body, only: [:create, :update]
  before_action :required_params, only: :create

  REQUIRED_PARAMS = [
    "name"
  ].freeze
  
  def index
    render json: MenuItem.all
  end

  def show
    render json: @menu_item
  end

  def create
    @menu_item = MenuItem.new(permitted_params)
        
    if @menu_item.save
      render json: @menu_item
    else
      render json: @menu_item.errors, status: :unprocessable_entity
    end
  end

  def update
    if @menu_item.update(permitted_params)
      render json: @menu_item
    else
      render json: @menu_item.errors, status: :unprocessable_entity
    end
  end

  def destroy
    MenuItemMenu.where(menu_item_id: @menu_item.id).destroy_all
    @menu_item.destroy

    head :no_content
  end

  private 

  def validate_empty_body
    render_error("No menu item attributes was passed as parameters.", :bad_request) if permitted_params.blank?
  end

  def required_params
    REQUIRED_PARAMS.each do |param|
      return render_error("Required param missing: #{param}", :bad_request) unless params[param]
    end
  end

  def permitted_params
    params.permit(
      :name, 
      :price_in_cents,
      :category,
      :description,
      :is_available,
      :calories,
      ingredients: [],
      allergens: []
    )
  end

  def set_menu_item
    @menu_item = MenuItem.find_by_id(params['id'])
    render_error("Invalid menu item id!", :not_found) if @menu_item.nil?
  end
end
