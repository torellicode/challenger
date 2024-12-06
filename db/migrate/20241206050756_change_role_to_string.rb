class ChangeRoleToString < ActiveRecord::Migration[7.1]
  def up
    # First, add a temporary column
    add_column :users, :role_string, :string
    
    # Update the temporary column based on the integer values
    execute <<-SQL
      UPDATE users 
      SET role_string = CASE role
        WHEN 0 THEN 'standard'
        WHEN 1 THEN 'basic'
        WHEN 2 THEN 'pro'
        WHEN 3 THEN 'admin'
        ELSE 'standard'
      END;
    SQL
    
    # Remove the old column and rename the new one
    remove_column :users, :role
    rename_column :users, :role_string, :role
    
    # Add a default value to the new column
    change_column_default :users, :role, 'standard'
  end

  def down
    # Add temporary integer column
    add_column :users, :role_int, :integer
    
    # Convert string roles back to integers
    execute <<-SQL
      UPDATE users 
      SET role_int = CASE role
        WHEN 'standard' THEN 0
        WHEN 'basic' THEN 1
        WHEN 'pro' THEN 2
        WHEN 'admin' THEN 3
        ELSE 0
      END;
    SQL
    
    # Remove the string column and rename the integer column
    remove_column :users, :role
    rename_column :users, :role_int, :role
    
    # Add default value
    change_column_default :users, :role, 0
  end
end
