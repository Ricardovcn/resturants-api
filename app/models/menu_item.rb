class MenuItem < ApplicationRecord
  belongs_to :menu, class_name: "Menu", foreign_key: "menu_id"
end
