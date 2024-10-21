require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  describe 'associations' do
    it { should have_many(:menus) }
    it { should have_many(:menu_items) }
  end

  describe 'validations' do
    subject { build(:restaurant) }

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(100) }

    it { should validate_length_of(:description).is_at_most(500).allow_nil }
    it { should allow_value("This is a valid description.").for(:description) }
    it { should allow_value(nil).for(:description) }
    it { should_not allow_value("   ").for(:description) }

    it { should_not allow_value("email").for(:email) }
    it { should allow_value("email@email.com").for(:email) }

    it { should_not allow_value("email").for(:phone_number) }
    it { should allow_value("+55 44 4444 444").for(:phone_number) }
  end

  describe 'callbacks' do
    it 'destroys associated menus before destroying the restaurant' do
      restaurant = create(:restaurant)
      create(:menu, restaurant: restaurant)

      expect { restaurant.destroy }.to change { Menu.count }.by(-1)
    end
  end

  describe 'callbacks' do
    it 'destroys associated menu_items before destroying the restaurant' do
      restaurant = create(:restaurant)
      create(:menu, restaurant: restaurant)
      create(:menu_item, restaurant: restaurant)

      expect { restaurant.destroy }.to change { MenuItem.count }.by(-1)
    end
  end
end