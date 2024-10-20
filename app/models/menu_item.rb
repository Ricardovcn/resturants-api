class MenuItem < ApplicationRecord
  has_many :menu_item_menus
  has_many :menus, through: :menu_item_menus
  belongs_to :restaurant, class_name: "Restaurant", foreign_key: "restaurant_id"

  before_destroy :remove_menu_item_associations

  validates :price_in_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :name, presence: true,  uniqueness: { scope: :restaurant_id, message: "must be unique within a restaurant" }, length: { maximum: 100 }
  validates :description, length: { maximum: 500 }, format: { without: /\A\s*\z/, message: "must contain non-whitespace characters" }, allow_nil: true
  validates :category, length: { maximum: 50 }, format: { without: /\A\s*\z/, message: "must contain non-whitespace characters" }, allow_nil: true
  validates :calories, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :is_available, inclusion: { in: [true, false], message: "must be true or false" }, allow_nil: false

  validate :validate_ingredients
  validate :validate_allergens
  
  
  def price=(value)
    if value.present? && value.is_a?(Numeric) && value >= 0
      self.price_in_cents = (BigDecimal(value.to_s) * 100).round
    else
      raise ArgumentError,  "Invalid price value for MenuItem. Expected a non-negative numeric value, but received: #{value}."
    end
  end

  def price
    price_in_cents.to_f / 100
  end

  def as_json(options = {}) 
    super(options.merge(methods: :price, except: :price_in_cents))
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
