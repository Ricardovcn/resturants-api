class AddPriceToMenuItem < ActiveRecord::Migration[6.0]
  def change
    add_column :menu_items, :price_in_cents, :integer
  end
end
