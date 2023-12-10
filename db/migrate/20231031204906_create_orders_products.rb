class CreateOrdersProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :orders_products do |t|
      t.references :product, null: false, foreign_key: true
      t.references :order, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.integer :price, null: false

      t.timestamps
    end
    add_check_constraint :orders_products, "price >= 0", name: "price_check"
    add_check_constraint :orders_products, "quantity > 0", name: "quantity_check"
  end
end
