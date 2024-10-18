module Restaurants
  class SerializeAndPersistService
    ALLOWED_RESTAURANT_ATTRIBUTES = [:name, :menus, :description, :phone_number, :email].freeze
    ALLOWED_MENU_ATTRIBUTES = [:name, :menu_items, :description, :is_acive].freeze
    ALLOWED_MENU_ITEM_ATTRIBUTES = [:name, :price, :category, :description, :ingredients, :is_available, :calories, :allergens].freeze

    def initialize(data)
      @data = data
      @logs = []
    end
    
    def call
      success = create_restaurants(@data[:restaurants])
      { success: success, logs: @logs }
    rescue ArgumentError => e
      @logs << "Error: #{e.message}."
      @logs << ". Nothing was added to the Database." if @logs.size > 1
      { success: false, logs: @logs, error_message: "Error: #{e.message}." }
    end

    private 

    def validate_required_param(data, param, context)
      raise ArgumentError.new("Invalid format Data. Required param '#{param}' missing for #{context}.") unless data.include?(param)
    end

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
        validate_required_param(restaurant, :name, "Restaurant")
        restaurant[:menus].each do |menu| 
          validate_permitted_attributes(menu, ALLOWED_MENU_ATTRIBUTES, "Menu")
          validate_required_param(menu, :name, "Menu")
          menu[:menu_items].each do |menu_item| 
            validate_permitted_attributes(menu_item, ALLOWED_MENU_ITEM_ATTRIBUTES, "MenuItem")
            validate_required_param(menu_item, :name, "Menu Item")
          end
        end
      end
    end
    
    def create_restaurants(restaurants_data)
      restaurants_data.each do |restaurant_data|
        restaurant = Restaurant.new(restaurant_data.except(:menus))

        if restaurant.save
          @logs << "Restaurant #{restaurant.name}} successfully created. ID: #{restaurant.id}}"
        else
          @logs << "Failed to create Restaurant. #{restaurant.errors.full_messages.join(", ")}"
          return false
        end
        
        return create_menus(restaurant_data[:menus], restaurant.id)        
      end
    end

    def create_menus(menus_data, restaurant_id)
      menus_data.each do |menu_data|
        menu = Menu.new(menu_data.except(:menu_items).merge(restaurant_id: restaurant_id))

        if menu.save
          @logs << "Menu #{menu.name}} successfully created. ID: #{menu.id}}"
        else
          @logs << "Failed to create Menu. #{menu.errors.full_messages.join(", ")}"
          return false
        end

        return create_menu_items(menu_data[:menu_items], menu.id)        
      end
    end

    def create_menu_items(menu_items_data, menu_id)
      menu_items_data.each do |menu_item_data|
        menu_item = MenuItem.find_by_name(menu_item_data[:name])

        if menu_item.present?
          @logs << "There's already an menu item with this name."
          @logs << "The existing object will be used instead of creating a new one."
        else
          menu_item = MenuItem.new(menu_item_data)
          if menu_item.save
            @logs << "MenuItem #{menu_item.name}} successfully created. ID: #{menu_item.id}}"
          else
            @logs << "Failed to create MenuItem. #{menu_item.errors.full_messages.join(", ")}"
            return false
          end
        end  
                
        menu_item_menu = MenuItemMenu.new(menu_item_id: menu_item.id, menu_id: menu_id)
        
        begin 
          if menu_item_menu.save
            logs << "Association Menu with MenuItem successfully created."
          else
            logs << "Fail to associate Menu with MenuItem. #{menu_item_menu.errors.full_messages.join(", ")}"
            return false
          end
        rescue ActiveRecord::RecordNotUnique
          logs << "Association Menu with MenuItem alredy exists"
        end
      end
      true

    end
  end
end