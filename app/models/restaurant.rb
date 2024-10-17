class Restaurant < ApplicationRecord
  before_destroy :remove_menu_item_associations
  has_many :menus, class_name: "Menu", dependent: :destroy


  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }, allow_blank: true
  validates :phone_number, format: { with: /\A\+?[0-9\s\-]+\z/, message: "must be a valid phone number", allow_blank: true }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  private

  def remove_menu_item_associations    
    MenuItemMenu.where(menu_id: menus.pluck(:id)).destroy_all
  end
end
