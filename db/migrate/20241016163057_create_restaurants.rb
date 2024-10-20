class CreateRestaurants < ActiveRecord::Migration[6.0]
  def change
    create_table :restaurants do |t|
      t.string :name
      t.string :description
      t.string :phone_number
      t.string :email

      t.timestamps
    end

    add_reference :menus, :restaurant, null: false, foreign_key: true 
  end
end
