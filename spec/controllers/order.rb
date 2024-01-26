require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe Order, type: :request do 
    before :context do
        @product = FactoryBot.create(:product)
        @customer = FactoryBot.create(:user)
        headers = { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
        # This will add a valid token for `user` in the `Authorization` header
        @customer_auth_headers = Devise::JWT::TestHelpers.auth_headers(headers, @customer)
    end   


    describe "order CRUD" do 
       
        it "logged out user should not create an order"  do 
            post '/orders'
            expect(response).to have_http_status(:unauthorized)
        end

        it "user can create an order"  do 
            params_orders = {
                products: [{
                    id: @product.id,
                    quantity: 5
                }]
            }
            post '/orders', params: params_orders, as: :json, headers: @customer_auth_headers

            response_json = JSON.parse(response.body)
            
            expect(response_json["status"]["code"]).to equal(200)
            expect(response_json["response"]["purchase_units"]).not_to be_nil
        end

        
        it "should mark order as paid"  do 
            put '/orders/1', as: :json, params: {order: {status: "paid"}}, headers: @customer_auth_headers
            response_json = JSON.parse(response.body)
            expect(response_json["status"]["code"]).to equal(200)
            expect(response_json["order"]["status"]).to eq("paid")
        end
        
    end
end