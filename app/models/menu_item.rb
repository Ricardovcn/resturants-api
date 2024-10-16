class MenuItem < ApplicationRecord
  has_many :menu_item_menus
  has_many :menus, through: :menu_item_menus

  before_destroy :remove_menu_item_associations

  validates :price_in_cents, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :name, uniqueness: true

  def price_in_dolar
    self.price_in_cents / 100.0
  end

  private 

  def remove_menu_item_associations
    menu_item_menus.destroy_all
  end
end
