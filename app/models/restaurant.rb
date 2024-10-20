class Restaurant < ApplicationRecord
  before_destroy :remove_menu_item_associations
  has_many :menus, class_name: "Menu", dependent: :destroy
  has_many :menu_items, class_name: "MenuItem", dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }, format: { without: /\A\s*\z/, message: "must contain non-whitespace characters" }, allow_nil: true
  validates :phone_number, format: { with: /\A\+?[0-9\s\-]+\z/, message: "must be a valid phone number", allow_blank: true }, length: { maximum: 16 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_nil: true

  private

  def remove_menu_item_associations    
    MenuItemMenu.where(menu_id: menus.pluck(:id)).destroy_all
  end
end
