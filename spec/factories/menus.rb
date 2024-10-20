FactoryBot.define do
  factory :menu do
    name { "Sample Menu" }
    description { "A descriptive menu description." }
    is_active { true }

    association :restaurant
  end
end