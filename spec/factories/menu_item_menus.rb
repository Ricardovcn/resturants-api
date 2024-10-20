FactoryBot.define do
  factory :menu_item_menu do
    association :menu_item
    association :menu
  end
end