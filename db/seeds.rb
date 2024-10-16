puts "Seeding Menus..."

names = [
  { name: "Menu Name 1" },
  { name: "Menu Name 2" },
]

names.each do |menu_name|
  Menu.find_or_create_by(menu_name)
  puts "Created menu: #{menu_name}"
end

puts "Seeding completed!"