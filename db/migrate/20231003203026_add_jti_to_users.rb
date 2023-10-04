class AddJtiToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :jti, :string, null: false, unique: true
    add_index :users, :jti, unique: true
  end
end
