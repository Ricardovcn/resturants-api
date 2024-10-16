puts "Seeding Menus..."

names = [
  { name: "Drinks Menu" },
  { name: "Fast Food Menu" },
]

names.each do |menu_name|
  Menu.find_or_create_by(menu_name)
  puts "Created menu: #{menu_name}"
end

puts "Seeding Menus items..."

drink_names = [
  { name: "Water", menu_id: 1 },
  { name: "Soda", menu_id: 1 },
  { name: "Mojito", menu_id: 1 }
]

fast_food_names = [
  { name: "Fries", menu_id: 2 },
  { name: "Hamburguer", menu_id: 2 },
  { name: "Pizza", menu_id: 2 }
]

drink_names.each do |drink|
  MenuItem.find_or_create_by(drink)
  puts "Created menu item: #{drink}"
end

fast_food_names.each do |fast_food|
  MenuItem.find_or_create_by(fast_food)
  puts "Created menu item: #{fast_food}"
end

puts "Seeding completed!"