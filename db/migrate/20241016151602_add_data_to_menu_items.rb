class AddDataToMenuItems < ActiveRecord::Migration[6.0]
  def change
    add_column :menu_items, :category, :string
    add_column :menu_items, :description, :string
    add_column :menu_items, :ingredients, :string, array: true, default: []
    add_column :menu_items, :is_available, :boolean, default: true
    add_column :menu_items, :calories, :integer
    add_column :menu_items, :allergens, :string, array: true, default: []
  end
end
