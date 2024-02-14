require 'rails_helper'

RSpec.describe CreateOrderWithProducts do
    let (:user) {
        FactoryBot.create(:user)
    }

    let(:product_one)  {
        FactoryBot.create(:product)
    }

    let(:order)  {
        user.orders.create
    }

    describe "AddProductToOrder call" do
        it "should change the product quantity by 3" do 
            expect{ 
                AddProductToOrder.new(order, product_one, 3).call
            }.to change(product_one, :quantity).by(-3) 
        end

        it "should change the product quantity to 0 when the order quantity exceeds the product quantity" do 
            expect{ 
                AddProductToOrder.new(order, product_one, 15).call
            }.to change(product_one, :quantity).by(-10) 
        end

        it "should return false when the product doesn't exist" do 
            product = nil
            expect(AddProductToOrder.new(order, product, 1).call).to eq(false)
        end

        it "should return correct paypal payload" do 
            product = nil
            response_json = AddProductToOrder.new(order, product_one, 1).call

            expect(response_json.keys).to include(:unit_amount)
            expect(response_json.keys).to include(:quantity)
            expect(response_json.keys).to include(:name)
            expect(response_json.keys).to include(:description)
            expect(response_json[:unit_amount][:value]).to eq(product_one.price)

        end

        it "should return false when product quantity is 0" do 
            product = FactoryBot.create(:product, quantity: 0) 
            expect(AddProductToOrder.new(order, product, 1).call).to eq(false)
        end

        it "should change the OrdersProduct count" do 
            expect { 
                AddProductToOrder.new(order, product_one, 1).call 
            }.to  change(OrdersProduct, :count)
        end
    end
end