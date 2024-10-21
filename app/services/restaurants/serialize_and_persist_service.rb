require_relative '../../utils/event_logger.rb'

module Restaurants
  class SerializeAndPersistService
    ALLOWED_RESTAURANT_ATTRIBUTES = [:name, :menus, :description, :phone_number, :email].freeze
    ALLOWED_MENU_ATTRIBUTES = [:name, :menu_items, :description, :is_active].freeze
    ALLOWED_MENU_ITEM_ATTRIBUTES = [:name, :price, :category, :description, :ingredients, :is_available, :calories, :allergens].freeze

    def initialize(data)
      @data = data
      @logger = EventLogger.new
    end
    
    def call            
      validate_data_format
      ActiveRecord::Base.transaction do
        success = create_restaurants(@data[:restaurants])
        
        @logger.log("Rollback", "Rolling back database changes.") if !success && @logger.all_logs.size > 1 
        return { success: success, logs: @logger.all_logs }
      end
    rescue ArgumentError => e
      @logger.log("Error",  ["#{e.message}"])
      @logger.log("Rollback", "Rolling back database changes due to error (#{ e.message }).") if @logger.all_logs.size > 1
      { success: false, logs: @logger.all_logs }
    end

    private 

    def validate_permitted_attributes(data, allowed_attributes, context)
      unpermitted_attributes = data.keys - allowed_attributes
  
      if unpermitted_attributes.any?
        raise ArgumentError.new("Invalid format Data. Unpermitted #{context} attributes: #{unpermitted_attributes.join(', ')}")
      end
    end

    def validate_data_format      
      raise ArgumentError.new("Invalid data format. It should be a Hash.") unless  @data.is_a?(Hash)
      @data.deep_symbolize_keys!
      raise ArgumentError.new("No restaurants found in the give JSON data.") if @data.blank? || !@data[:restaurants].is_a?(Array) || @data[:restaurants].blank?
      
      @data[:restaurants].each do |restaurant| 
        validate_permitted_attributes(restaurant, ALLOWED_RESTAURANT_ATTRIBUTES, "Restaurant")
        restaurant[:menus]&.each do |menu| 
          validate_permitted_attributes(menu, ALLOWED_MENU_ATTRIBUTES, "Menu")
          menu[:menu_items]&.each do |menu_item| 
            validate_permitted_attributes(menu_item, ALLOWED_MENU_ITEM_ATTRIBUTES, "MenuItem")
          end
        end
      end
    end
    
    def create_restaurants(restaurants_data)
      restaurants_data.each do |restaurant_data|        
        restaurant = Restaurant.new(restaurant_data.except(:menus))

        if restaurant.save
          @logger.log("Create Restaurant", ["Restaurant #{restaurant.name} successfully created"], { id: restaurant.id })
        else
          @logger.log("Error", ["Failed to create Restaurant #{restaurant_data[:name]}. #{restaurant.errors.full_messages.join(", ")}"])
          return false
        end
        
        @restaurant_created_menu_items = []
        success = restaurant_data[:menus].present? ? create_menus(restaurant_data[:menus], restaurant) : true
        return success unless success     
      end

      true
    end

    def create_menus(menus_data, restaurant)
      menus_data.each do |menu_data|
        menu = Menu.new(menu_data.except(:menu_items).merge(restaurant_id: restaurant.id))

        if menu.save
          @logger.log("Create Menu", ["Menu #{menu.name} successfully created"], { id: menu.id })
        else
          @logger.log("Error", ["Failed to create Menu #{menu_data[:name]}. #{menu.errors.full_messages.join(", ")}"])
          return false
        end

        success = menu_data[:menu_items].present? ? create_menu_items(menu_data[:menu_items], menu.id, restaurant) : true
        return success unless success         
      end
    end

    def create_menu_items(menu_items_data, menu_id, restaurant)
      menu_items_data.each do |menu_item_data|
        messages = []
        menu_item = @restaurant_created_menu_items.find { |create_menu_item| create_menu_item.name == menu_item_data[:name]}
                        
        if menu_item.present?
          messages = ["MenuItem #{menu_item_data[:name]} already exists for the restaurant #{restaurant[:name]}.", "The existing object will be used instead of creating a new one."] 
        else
          menu_item = MenuItem.new(menu_item_data.merge(restaurant_id: restaurant.id))
          if menu_item.save
            messages << "MenuItem #{menu_item.name} successfully created."
            @restaurant_created_menu_items << menu_item.clone
          else
            @logger.log("Error", ["Failed to create MenuItem #{menu_item_data[:name]}. #{menu_item.errors.full_messages.join(", ")}"])
            return false
          end
        end  
        
        menu_item_menu = MenuItemMenu.find_by(menu_item_id: menu_item.id, menu_id: menu_id)
        
        if menu_item_menu.present?
          messages << "The MenuItem (ID: #{menu_item.id}) is already associated with the Menu (ID: #{menu_id})"
          @logger.log("Create MenuItem ", messages, { id: menu_item.id })
        else
          menu_item_menu = MenuItemMenu.new(menu_item_id: menu_item.id, menu_id: menu_id)

          if menu_item_menu.save
            messages << "MenuItem (ID: #{menu_item.id}) successfully associated with Menu (ID: #{menu_id})."
            @logger.log("Create MenuItem ", messages, { id: menu_item.id })
          else
            messages << "Fail to associate Menu (ID: #{menu_id}) with MenuItem  (ID: #{menu_item.id}). #{menu_item_menu.errors.full_messages.join(", ")}"
            @logger.log("Error", messages)
            return false
          end
        end
      end
    end
  end
end