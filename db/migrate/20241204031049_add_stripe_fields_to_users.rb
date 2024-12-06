class AddStripeFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :stripe_subscription_id, :string
    add_column :users, :subscription_status, :string
    
    add_index :users, :stripe_subscription_id
  end
end
