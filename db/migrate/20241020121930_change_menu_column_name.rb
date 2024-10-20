class ChangeMenuColumnName < ActiveRecord::Migration[6.0]
  def change
    rename_column :menus, :is_acive, :is_active
  end
end
