class AddUsersAssociationToProducts < ActiveRecord::Migration[7.0]
  def up
    add_reference :products, :user, foreign_key: true
    Product.destroy_all
  end

  def down
    remove_reference :products, :user
  end
end
