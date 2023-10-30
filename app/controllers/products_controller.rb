class ProductsController < ApplicationController
    before_action :authenticate_user!, only: :create

    def index
      render json: Product.all
    end
  
    def create
        product = current_user.products.create(product_params)
        if product.errors.empty?
            render json: {
                status: {code: 200},
                product: product
            }
        else
            render json: {
                status: {code: 422, errors: product.errors},
            }
        end
    end

    private
    def product_params
        params.require(:product).permit(:name, :description, :price)
    end
  end
  