class AddRestaurantIdToMenuItems < ActiveRecord::Migration[6.0]
  def change
    add_reference :menu_items, :restaurant, foreign_key: true

    remove_index :menu_items, :name
    add_index :menu_items, [:restaurant_id, :name], unique: true
  end
end
