FactoryBot.define do
  factory :restaurant do
    name { "Sample Restaurant" }
    description { "A descriptive restaurant description." }
    email { "rest_email@gmail.com" }
    phone_number { "+44 444 4444" }
  end
end