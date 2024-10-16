class Restaurant < ApplicationRecord
  before_destroy :remove_menu_item_associations
  has_many :menus, class_name: "Menu", dependent: :destroy

  private

  def remove_menu_item_associations    
    MenuItemMenu.where(menu_id: menus.pluck(:id)).destroy_all
  end
end
