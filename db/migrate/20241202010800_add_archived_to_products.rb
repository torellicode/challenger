class AddArchivedToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :archived, :boolean, default: false
    add_index :products, :archived
  end
end
