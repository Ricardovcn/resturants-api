class Menu < ApplicationRecord
  has_many :menu_items, class_name: "MenuItem"
end
