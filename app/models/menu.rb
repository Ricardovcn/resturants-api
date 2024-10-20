class Menu < ApplicationRecord
  has_many :menu_item_menus
  has_many :menu_items, through: :menu_item_menus
  
  belongs_to :restaurant, class_name: "Restaurant", foreign_key: "restaurant_id"

  before_destroy :remove_menu_item_associations

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }, format: { without: /\A\s*\z/, message: "must contain non-whitespace characters" }, allow_nil: true
  validates :is_active, inclusion: { in: [true, false], message: "must be true or false" }, allow_nil: false

  private 

  def remove_menu_item_associations
    menu_item_menus.destroy_all
  end
end
