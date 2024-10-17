module Restaurants
  class ImportService
    def initialize(data)
      @data = data
      @menu_item_logs = []
    end
    
    def serialize_and_persist
      import_restaurants(@data["restaurants"])
      @menu_item_logs
    end

    private 

    def import_restaurants(restaurants_data)
      restaurants_data.each do |restaurant_data|
        logs = []
        restaurant = Restaurant.new(restaurant_data.except("menus"))

        if restaurant.save
          logs << "Restaurant #{restaurant.name}} successfully created. ID: #{restaurant.id}}"
        else
          logs << "Failed to create Restaurant. #{restaurant.errors.full_messages.join(", ")}"
        end
        
        import_menus(restaurant_data["menus"], restaurant&.id, logs)        
      end
    end

    def import_menus(menus_data, restaurant_id, restaurant_logs)
      menus_data.each do |menu_data|
        logs = restaurant_logs.dup

        if restaurant_id.nil?
          logs << "Failed to create Menu because Restaurant does no exist."
          import_menu_items(menu_data["menu_items"], nil, logs)
        end

        menu = Menu.new(menu_data.except("menu_items").merge(restaurant_id: restaurant_id))

        if menu.save
          logs << "Menu #{menu.name}} successfully created. ID: #{menu.id}}"
        else
          logs << "Failed to create Menu. #{menu.errors.full_messages.join(", ")}"
        end

        import_menu_items(menu_data["menu_items"], menu&.id, logs)        
      end
    end

    def import_menu_items(menu_items_data, menu_id, menu_logs)
      menu_items_data.each do |menu_item_data|
        logs = menu_logs.dup
        if menu_id.nil?
          logs << "Failed to create MenuItem because Menu does no exist."
          set_logs(menu_item_data, logs)
          next
        end

        success = true
        menu_item = MenuItem.find_by_name(menu_item_data["name"])

        if menu_item.present?
          logs << "There's already an menu item with this name."
          logs << "The existing object will be used instead of creating a new one."
        else
          menu_item = MenuItem.new(menu_item_data)
          if menu_item.save
            logs << "MenuItem #{menu_item.name}} successfully created. ID: #{menu_item.id}}"
          else
            logs << "Failed to create MenuItem. #{menu_item.errors.full_messages.join(", ")}"
            success = false
          end
        end  
        
        unless success
          set_logs(menu_item_data, logs) 
          next 
        end
        
        menu_item_menu = MenuItemMenu.new(menu_item_id: menu_item.id, menu_id: menu_id)
        
        begin 
          if menu_item_menu.save
            logs << "Association Menu with MenuItem successfully created."
            success = true
          else
            logs << "Fail to associate Menu with MenuItem. #{menu_item_menu.errors.full_messages.join(", ")}"
            success = false
          end
        rescue ActiveRecord::RecordNotUnique
          logs << "Association Menu with MenuItem alredy exists"
          success = true
        end

        set_logs(menu_item_data, logs, success) 
      end
    end

    def set_logs(menu_item, list_of_logs, success = false)
      @menu_item_logs << {
        success: success,
        menu_item: menu_item,
        logs: list_of_logs
      }
    end
  end
end