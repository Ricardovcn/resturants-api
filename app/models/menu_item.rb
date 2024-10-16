class MenuItem < ApplicationRecord
  belongs_to :menu, class_name: "Menu", foreign_key: "menu_id"
  
  validates :price_in_cents, numericality: { only_integer: true, greater_than: 0 }

  def price_in_dolar
    self.price_in_cents / 100.0
  end
end
