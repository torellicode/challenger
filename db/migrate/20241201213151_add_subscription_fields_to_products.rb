class AddSubscriptionFieldsToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :product_type, :string, default: 'subscription'
    add_column :products, :billing_period, :string
  end
end
