require 'rails_helper'

RSpec.describe CreateOrderWithProducts do
    let (:user) {
        FactoryBot.create(:user)
    }

    let(:product_one)  {
        FactoryBot.create(:product)
    }

    describe "CreateOrderWithProducts call" do 

        it "should create order record" do
            expect{ 
                CreateOrderWithProducts.new([{id: product_one.id, quantity: 1}], user).call
            }.to change(Order, :count).by(1) 
        end

        it "should create order products" do 
            expect{ 
                CreateOrderWithProducts.new([{id: product_one.id, quantity: 1}], user).call
            }.to change(OrdersProduct, :count).by(1) 
        end

        it "order_record should have appropriate total" do 
            CreateOrderWithProducts.new([{id: product_one.id, quantity: 2}], user).call
            expect(Order.last.total).to eq product_one.price * 2
        end

        it "order_record should instantiate addProductToOrder service object" do
            # lookup how to assert methods are called on objects in Rspec
            expect(AddProductToOrder).to receive(:new).with(:call)
            CreateOrderWithProducts.new([{id: product_one.id, quantity: 1}], user).call
        end

        it "should fail when a product does not exist " do
            expect{ 
                CreateOrderWithProducts.new([
                    {id: product_one.id, quantity: 1}, 
                    {id: 2, quantity: 1}
                ], user).call

            }.not_to change(Order, :count)
        end

    end

end