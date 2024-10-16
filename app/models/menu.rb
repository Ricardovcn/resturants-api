class Menu < ApplicationRecord
  has_many :menu_items, class_name: "MenuItem"
  
  belongs_to :restaurant, class_name: "Restaurant", foreign_key: "restaurant_id"
end
