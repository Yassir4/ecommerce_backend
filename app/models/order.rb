class Order < ApplicationRecord
  belongs_to :user
  has_many :orders_products
  has_many :products, through: :orders_products
  before_update :calculate_total


  enum :status, [:pending, :paid, :cancelled]

  def add_product(product, quantity)
    price = quantity * product.price
    orders_products.create(product: product, quantity: quantity, price: price )
  end

  private

  def calculate_total
    current_total = 0
    orders_products.each do |product|
      # change this after adding the product unique constraint
      current_total += product.price  || 0
    end
    self.total = current_total
  end

end