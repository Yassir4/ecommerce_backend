require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe Product, type: :request do 
    before :context do
        @user_with_product = FactoryBot.create(:user)
        @customer = FactoryBot.create(:user)
        FactoryBot.create(:category)
        headers = { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
        # This will add a valid token for `user` in the `Authorization` header
        @userp_auth_headers = Devise::JWT::TestHelpers.auth_headers(headers, @user_with_product)
        @customer_auth_headers = Devise::JWT::TestHelpers.auth_headers(headers, @customer)
    end    

    describe "user product CRUD" do
        it "is invalid without valid attributes" do
            product_params = {
                product: {description: 'value'}
            }
            post '/products', params: product_params , as: :json, headers: @userp_auth_headers

            expect(response).to have_http_status(422)
        end

        it "is valid with valid attributes" do
            product_params = {
                product: {description: 'value', name: 'product', price: '10.33', category_id: 1}
            }
            post '/products', params: product_params , as: :json, headers: @userp_auth_headers

            expect(response).to have_http_status(200)
            
        end

        it "user can update product" do
            product_params = {
                product: {description: 'value', name: 'product update', price: '10.33', category_id: 1}
            }

            put '/products/1', params: product_params , as: :json, headers: @userp_auth_headers

            expect(response).to have_http_status(200)
            
        end

        it 'customer should not update a product' do
            product_params = {
                product: {description: 'value', name: 'product update', price: '10.33', category_id: 1}
            }

            put '/products/1', params: product_params , as: :json, headers: @customer_auth_headers
            expect(response).to have_http_status(:unauthorized)
        end

        it 'logged out customer should get the product' do
            get '/products/1'

            response_json = JSON.parse(response.body)
            expect(response).to have_http_status(200)
            expect(response_json["product"]).not_to be_nil
        end

        it 'logged out customer should not delete order' do
            delete '/products/1'
            expect(response).to have_http_status(:unauthorized)            
        end
        
        it 'product owner can delete order' do
            delete '/products/1', headers: @userp_auth_headers
            expect(response).to have_http_status(:ok)         
            get  '/products/1'
            expect(response).to have_http_status(:not_found)
        end

        it "normal customer can't delete the order"
        it "admin can delete and update orders"
    end
end