class Restaurant < ApplicationRecord
  has_many :menus, class_name: "Menu", dependent: :destroy
end
