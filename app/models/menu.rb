class Menu < ApplicationRecord
  has_many :menu_item_menus
  has_many :menu_items, through: :menu_item_menus
  
  belongs_to :restaurant, class_name: "Restaurant", foreign_key: "restaurant_id"

  before_destroy :remove_menu_item_associations

  private 

  def remove_menu_item_associations
    menu_item_menus.destroy_all
  end
end
