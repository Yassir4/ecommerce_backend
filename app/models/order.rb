class Order < ApplicationRecord
  belongs_to :user
  has_many :orders_products
  has_many :products, through: :orders_products
  before_save :calculate_total

  def add_products(products = [])
    products.each do |product|
      orders_products.create(product: product, quantity: 1, price: product.price)
    end
  end

  def calculate_total
    current_total = 0
    products.each do |product|
      # change this after adding the product unique constraint
      current_total += product.price
    end
    total = current_total
    # save
  end

end
