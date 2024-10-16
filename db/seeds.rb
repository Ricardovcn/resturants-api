puts "Seeding Restaurants..."

restaurant_names = [
  { name: "Restaurant Name 1" },
  { name: "Restaurant Name 2" },
]

restaurant_names.each do |menu_name|
  Restaurant.find_or_create_by(menu_name)
  puts "Created restaurant: #{menu_name}"
end

puts "Seeding Menus..."

menu_names = [
  { name: "Drinks Menu", restaurant_id: 1 },
  { name: "Fast Food Menu", restaurant_id: 1 },
]

menu_names.each do |menu_name|
  Menu.find_or_create_by(menu_name)
  puts "Created menu: #{menu_name}"
end

puts "Seeding Menus items..."

drink_names = [
  { name: "Water"},
  { name: "Soda"},
  { name: "Mojito"}
]

fast_food_names = [
  { name: "Fries"},
  { name: "Hamburguer"},
  { name: "Pizza"}
]

drink_names.each do |drink|
  menu_item = MenuItem.find_or_create_by(drink)
  puts "Created menu item: #{drink}"
  MenuItemMenu.find_or_create_by({menu_id: 2, menu_item_id: menu_item.id})
end

fast_food_names.each do |fast_food|
  menu_item =MenuItem.find_or_create_by(fast_food)
  puts "Created menu item: #{fast_food}"
  MenuItemMenu.find_or_create_by({menu_id: 2, menu_item_id: menu_item.id})
end

puts "Seeding completed!"