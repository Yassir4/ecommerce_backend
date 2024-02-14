class Order < ApplicationRecord
  belongs_to :user
  has_many :orders_products
  has_many :products, through: :orders_products



  enum :status, [:pending, :paid, :cancelled]

  def add_product(product, quantity, price)
    orders_products.create(product: product, quantity: quantity, price: price )
  end
 
end