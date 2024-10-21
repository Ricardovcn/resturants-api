require 'rails_helper'

RSpec.describe Menu, type: :model do
  describe 'associations' do
    it { should belong_to(:restaurant).class_name("Restaurant").with_foreign_key("restaurant_id") }
    it { should have_many(:menu_item_menus) }
    it { should have_many(:menu_items).through(:menu_item_menus) }
  end

  describe 'validations' do
    subject { build(:menu) }

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(100) }

    it { should validate_length_of(:description).is_at_most(500).allow_nil }
    it { should allow_value("This is a valid description.").for(:description) }
    it { should allow_value(nil).for(:description) }
    it { should_not allow_value("   ").for(:description) }

    it { should allow_value(true).for(:is_active) }
    it { should allow_value(false).for(:is_active) }
    it { should_not allow_value("").for(:is_active) }
  end

  describe 'callbacks' do
    it 'destroys associated menu_item_menus before destroying the menu' do
      menu = create(:menu)
      create(:menu_item_menu, menu: menu)

      expect { menu.destroy }.to change { MenuItemMenu.count }.by(-1)
    end
  end
end