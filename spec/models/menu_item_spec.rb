require 'rails_helper'

RSpec.describe MenuItem, type: :model do
  describe 'associations' do
    it { should belong_to(:restaurant).class_name('Restaurant').with_foreign_key('restaurant_id') }
    it { should have_many(:menu_item_menus) }
    it { should have_many(:menus).through(:menu_item_menus) }
  end

  describe 'validations' do
    subject { build(:menu_item) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(100) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:restaurant_id).with_message("must be unique within a restaurant") }

    it { is_expected.to validate_length_of(:description).is_at_most(500).allow_nil }
    it { is_expected.to allow_value("A valid description").for(:description) }
    it { is_expected.not_to allow_value("   ").for(:description).with_message("must contain non-whitespace characters") }

    it { is_expected.to validate_length_of(:category).is_at_most(50).allow_nil }
    it { is_expected.to allow_value("Appetizer").for(:category) }
    it { is_expected.not_to allow_value("   ").for(:category).with_message("must contain non-whitespace characters") }
    
    it { is_expected.to validate_numericality_of(:price_in_cents).only_integer.is_greater_than_or_equal_to(0).allow_nil }
    it { is_expected.to allow_value(55).for(:price_in_cents) }
    it { is_expected.to allow_value(nil).for(:price_in_cents) }
    it { is_expected.not_to allow_value(55.8).for(:price_in_cents) }
    it { is_expected.not_to allow_value("55,5").for(:price_in_cents) }
    it { is_expected.not_to allow_value("words").for(:price_in_cents) }

    it { is_expected.to validate_numericality_of(:calories).only_integer.is_greater_than_or_equal_to(0).allow_nil }
    it { is_expected.to allow_value(55).for(:calories) }
    it { is_expected.to allow_value(nil).for(:calories) }
    it { is_expected.not_to allow_value(55.8).for(:calories) }
    it { is_expected.not_to allow_value("55,5").for(:calories) }
    it { is_expected.not_to allow_value("words").for(:calories) }

    it { should allow_value(true).for(:is_available) }
    it { should allow_value(false).for(:is_available) }
    it { should_not allow_value("").for(:is_available) }
  end

  describe 'custom validation' do
    it 'validates ingredients' do
      menu_item = build(:menu_item)
      menu_item.ingredients = ['Salt', 'Pepper', SecureRandom.hex(51)]
      menu_item.valid?
      expect(menu_item.errors[:ingredients]).to include("must be an array of strings with a maximum length of 100 characters")
    end

    it 'validates allergens' do
      menu_item = build(:menu_item)
      menu_item.allergens = ['Nuts', 'Dairy', SecureRandom.hex(51)]
      menu_item.valid?
      expect(menu_item.errors[:allergens]).to include("must be an array of strings with a maximum length of 100 characters")
    end
  end

  describe '#price' do
    it 'returns price in dollars' do
      menu_item = build(:menu_item, price_in_cents: 1000)
      expect(menu_item.price).to eq(10.0)
    end
  end

  describe '#price=' do
    it 'sets price in cents correctly' do
      menu_item = build(:menu_item)
      menu_item.price = 10.50
      expect(menu_item.price_in_cents).to eq(1050)
    end

    it 'raises an error for invalid price' do
      menu_item = build(:menu_item)
      expect { menu_item.price = -5 }.to raise_error(ArgumentError, "Invalid price value for MenuItem. Expected a non-negative numeric value, but received: -5.")
    end

    it 'raises an error for non-numeric price' do
      menu_item = build(:menu_item)
      expect { menu_item.price = 'invalid' }.to raise_error(ArgumentError, "Invalid price value for MenuItem. Expected a non-negative numeric value, but received: invalid.")
    end
  end

  describe 'callbacks' do
    it 'destroys associated menu_item_menus before destroying the menu_item' do
      menu_item = create(:menu_item)
      create(:menu_item_menu, menu_item: menu_item)

      expect { menu_item.destroy }.to change { MenuItemMenu.count }.by(-1)
    end
  end
end