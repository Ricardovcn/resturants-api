puts "Seeding Restaurants..."

fancy_restaurant = Restaurant.find_or_create_by!({ name: "Fancy One" })
plain_restaurant = Restaurant.find_or_create_by!({ name: "Plain One" })

puts "Seeding Menus..."

drinks_menu = Menu.find_or_create_by!({ name: "Drinks Menu", restaurant_id: plain_restaurant.id })
fast_food_menu = Menu.find_or_create_by!({ name: "Fast Food Menu", restaurant_id: plain_restaurant.id })
  
puts "Seeding Menus items..."

water = MenuItem.find_or_create_by!({ restaurant_id: drinks_menu.restaurant_id, name: "Water"})
soda = MenuItem.find_or_create_by!({ restaurant_id: drinks_menu.restaurant_id, name: "Soda"})
mojito = MenuItem.find_or_create_by!({ restaurant_id: drinks_menu.restaurant_id, name: "Mojito"})

fries = MenuItem.find_or_create_by!({ restaurant_id: fast_food_menu.restaurant_id, name: "Fries"})
hamburguer = MenuItem.find_or_create_by!({ restaurant_id: fast_food_menu.restaurant_id, name: "Hamburguer"})
pizza = MenuItem.find_or_create_by!({ restaurant_id: fast_food_menu.restaurant_id, name: "Pizza"})

puts "Seedings Associations"

MenuItemMenu.find_or_create_by!({ menu_id: drinks_menu.id, menu_item_id: water.id })
MenuItemMenu.find_or_create_by!({ menu_id: drinks_menu.id, menu_item_id: soda.id })
MenuItemMenu.find_or_create_by!({menu_id: drinks_menu.id, menu_item_id: mojito.id })

MenuItemMenu.find_or_create_by!({ menu_id: fast_food_menu.id, menu_item_id: fries.id })
MenuItemMenu.find_or_create_by!({ menu_id: fast_food_menu.id, menu_item_id: hamburguer.id })
MenuItemMenu.find_or_create_by!({ menu_id: fast_food_menu.id, menu_item_id: pizza.id })


puts "Seeding completed!"