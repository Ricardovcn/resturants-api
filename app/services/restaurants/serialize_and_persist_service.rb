require_relative '../../utils/event_logger.rb'

module Restaurants
  class SerializeAndPersistService
    ALLOWED_RESTAURANT_ATTRIBUTES = [:name, :menus, :description, :phone_number, :email].freeze
    ALLOWED_MENU_ATTRIBUTES = [:name, :menu_items, :description, :is_acive].freeze
    ALLOWED_MENU_ITEM_ATTRIBUTES = [:name, :price, :category, :description, :ingredients, :is_available, :calories, :allergens].freeze

    def initialize(data)
      @data = data
      @logger = EventLogger.new
    end
    
    def call            
      validate_data_format
      success = create_restaurants(@data[:restaurants])
      { success: success, logs: @logger.all_logs }
    rescue ArgumentError => e
      messages = [ "Error: #{e.message}." ]
      messages << "Database Rollback executed. Nothing was added to the Database." if @logger.all_logs.size > 1
      
      @logger.log("Error", messages)
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
        restaurant[:menus].each do |menu| 
          validate_permitted_attributes(menu, ALLOWED_MENU_ATTRIBUTES, "Menu")
          menu[:menu_items].each do |menu_item| 
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
          @logger.log("Error", ["Failed to create Restaurant. #{restaurant.errors.full_messages.join(", ")}"])
          return false
        end
        
        success = create_menus(restaurant_data[:menus], restaurant.id)   
        return success unless success     
      end

      true
    end

    def create_menus(menus_data, restaurant_id)
      menus_data.each do |menu_data|
        menu = Menu.new(menu_data.except(:menu_items).merge(restaurant_id: restaurant_id))

        if menu.save
          @logger.log("Create Menu", ["Menu #{menu.name} successfully created"], { id: menu.id })
        else
          @logger.log("Error", ["Failed to create Menu. #{menu.errors.full_messages.join(", ")}"])
          return false
        end

        success = create_menu_items(menu_data[:menu_items], menu.id)
        return success unless success         
      end
    end

    def create_menu_items(menu_items_data, menu_id)
      menu_items_data.each do |menu_item_data|
        messages = []
        menu_item = MenuItem.find_by_name(menu_item_data[:name])

        if menu_item.present?
          messages << "There's already an menu item with this name."
          messages << "The existing object will be used instead of creating a new one."
        else
          menu_item = MenuItem.new(menu_item_data)
          if menu_item.save
            @logger.log("Create MenuItem", ["MenuItem #{menu_item.name}} successfully created."], { id: menu_item.id })
          else
            @logger.log("Error", ["Failed to create MenuItem. #{menu_item.errors.full_messages.join(", ")}"])
            return false
          end
        end  
                
        menu_item_menu = MenuItemMenu.new(menu_item_id: menu_item.id, menu_id: menu_id)
        
        begin 
          if menu_item_menu.save
            messages << "Association Menu with MenuItem successfully created."
            @logger.log("Create Association ", messages)
          else
            messages << "Fail to associate Menu with MenuItem. #{menu_item_menu.errors.full_messages.join(", ")}"
            @logger.log("Error", messages)
            return false
          end
        rescue ActiveRecord::RecordNotUnique
          messages << "This MenuItem is already associated with the Menu"
          @logger.log("Create Association ", messages)
        end
      end
    end
  end
end