class AddRoleToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :role, :string
    add_index :products, :role
  end
end
