class AddDataToMenu < ActiveRecord::Migration[6.0]
  def change
    add_column :menus, :description, :string
    add_column :menus, :is_acive, :boolean, default: true
  end
end
