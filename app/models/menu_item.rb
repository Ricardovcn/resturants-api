class MenuItem < ApplicationRecord
  has_many :menu_item_menus
  has_many :menus, through: :menu_item_menus

  before_destroy :remove_menu_item_associations

  validates :price_in_cents, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :name, uniqueness: true, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }, allow_blank: true
  validates :calories, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  validate :validate_ingredients
  validate :validate_allergens
  
  def price_in_dolar
    self.price_in_cents / 100.0
  end

  private 

  def validate_ingredients
    if ingredients.any?
      ingredients.each do |ingredient|
        unless ingredient.is_a?(String) && ingredient.length <= 100
          errors.add(:ingredients, "must be an array of strings with a maximum length of 100 characters")
        end
      end
    end
  end

  def validate_allergens
    if allergens.any?
      allergens.each do |allergen|
        unless allergen.is_a?(String) && allergen.length <= 100
          errors.add(:allergens, "must be an array of strings with a maximum length of 100 characters")
        end
      end
    end
  end

  def remove_menu_item_associations
    menu_item_menus.destroy_all
  end
end
