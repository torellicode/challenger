class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description
      t.integer :price_in_cents, null: false
      t.string :stripe_product_id
      t.string :stripe_price_id
      t.boolean :published, default: false
      t.timestamps
    end

    add_index :products, :stripe_product_id, unique: true
    add_index :products, :stripe_price_id, unique: true
    add_index :products, :published
  end
end
