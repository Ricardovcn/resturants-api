class MenuItem < ApplicationRecord
  has_many :menu_item_menus
  has_many :menus, through: :menu_item_menus

  validates :price_in_cents, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :name, uniqueness: true

  def price_in_dolar
    self.price_in_cents / 100.0
  end
end
