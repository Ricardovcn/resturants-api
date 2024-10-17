class AddUniqueIndexToMenuItemName < ActiveRecord::Migration[6.0]
  def change
    add_index :menu_items, :name, unique: true
  end
end
