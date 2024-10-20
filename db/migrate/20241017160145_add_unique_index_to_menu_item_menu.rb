class AddUniqueIndexToMenuItemMenu < ActiveRecord::Migration[6.0]
  def change
    add_index :menu_item_menus, [:menu_id, :menu_item_id], unique: true
  end
end
