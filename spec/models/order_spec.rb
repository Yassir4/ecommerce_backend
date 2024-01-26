require 'rails_helper'

RSpec.describe Order, type: :model do
  before :example do
    @user = FactoryBot.create(:user)
    @order = FactoryBot.create(:order, user: @user)
    @product = FactoryBot.create(:product)
  end

  describe 'save order' do
    it 'should update the total through the sum of products prices' do
      @order.orders_products.create(product: @product, quantity: 2, price: @product.price)
      
      expect(@order.total).to eq(nil)
      @order.save!

      expect(@order.total).to eq(2 * @product.price)
    end

  end
end
