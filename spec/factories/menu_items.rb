FactoryBot.define do
  factory :menu_item do
    name { "Sample Menu" }
    description { "A descriptive menu description." }
    price_in_cents { 1900}
    category { "Category"}
    ingredients { ["ingredient_1", "ingredient_2"] }
    is_available { true }
    calories { 600 }
    allergens { ["allergens_1", "allergens_2"]}

    association :restaurant
  end
end
