class Api::V1::RestaurantsController < ApplicationController
  
  before_action :set_restaurant, only: [:show, :update, :destroy]
  before_action :validate_empty_body, only: [:create, :update]
  before_action :required_params, only: :create

  REQUIRED_PARAMS = [
    "name"
  ].freeze
  
  def index
    render json: Restaurant.all
  end

  def show
    render json: @restaurant
  end

  def create
    @restaurant = Restaurant.new(permitted_params)

    if @restaurant.save
      render json: @restaurant
    else
      render json: @restaurant.errors, status: :unprocessable_entity
    end
  end

  def update
    if @restaurant.update(permitted_params)
      render json: @restaurant
    else
      render json: @restaurant.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @restaurant.destroy
    head :no_content
  end

  private

  def permitted_params
    params.permit(
      :name,
      :description,
      :phone_number,
      :email
    )
  end

  def validate_empty_body
    render_error("No restaurant attributes was passed as parameters.", :bad_request) if permitted_params.blank?
  end

  def required_params
    REQUIRED_PARAMS.each do |param|
      return render_error("Required param missing: #{param}", :bad_request) unless params[param]
    end
  end

  def set_restaurant
    return unless params['id'].present?

    @restaurant = Restaurant.find_by_id(params['id'])
    render_error("Invalid restaurant id!", :not_found) if @restaurant.nil?
  end
end
