class Api::V1::MenusController < ApplicationController
  before_action :set_menu, only: [:show, :update, :destroy, :menu_items]
  before_action :validate_empty_body, only: [:create, :update]
  before_action :required_params, only: :create

  REQUIRED_PARAMS = [
    "name",
    "restaurant_id"
  ].freeze
  
  def index
    render json: Menu.all
  end

  def show
    render json: @menu
  end

  def create
    @menu = Menu.new(permitted_params)

    if @menu.save
      render json: @menu
    else
      render json: @menu.errors, status: :unprocessable_entity
    end
  end

  def update
    if @menu.update(permitted_params)
      render json: @menu
    else
      render json: @menu.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @menu.destroy

    head :no_content
  end

  def menu_items
    render json: @menu.menu_items
  end

  private 

  def validate_empty_body
    render_error("No menu attributes was passed as parameters.", :bad_request) if permitted_params.blank?
  end

  def required_params
    REQUIRED_PARAMS.each do |param|
      return render_error("Required param missing: #{param}", :bad_request) unless params[param]
    end
  end

  def permitted_params
    params.permit(:name, :description, :is_acive, :restaurant_id)
  end

  def set_menu
    @menu = Menu.find_by_id(params['id'])
    render_error("Invalid menu id!", :not_found) if @menu.nil?
  end
end
