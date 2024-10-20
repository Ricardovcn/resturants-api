class CreateMenuItemMenus < ActiveRecord::Migration[6.0]
  def change
    remove_column :menu_items, :menu_id, :integer

    create_table :menu_item_menus do |t|
      t.references :menu, null: false, foreign_key: true
      t.references :menu_item, null: false, foreign_key: true

      t.timestamps
    end
  end
end
