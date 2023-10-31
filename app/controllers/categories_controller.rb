class CategoriesController < ApplicationController
  before_action :is_admin_user,     only: [:update, :destroy]
  def index
    render json: Category.all
  end

  def show
    category = find_category(params[:id])
  
    render json: {
      category: category
    }
  end

  def update
    category = find_category(params[:id])
    if category.update(category_params)
      render json: {
          status: { code: 200 },
          category: category
      }
    end
  end

  def destroy
    category = find_category(params[:id])
    if category.products.exists?
      render json: {
        errors: 'Category has products',
        status: {code: 409}
      }
    elsif category.destroy
        render json: {
            status: { code: 200 }
        }
    end
  end

  def find_category(category_id)
    begin
      category = Category.find(category_id)
      if category.present?
            return category
      end
    rescue ActiveRecord::RecordNotFound
        render json: {
            status: :not_found
        }
    end
    return
  end


  private

  def is_admin_user
    render json: {status: :unauthorized} unless current_user && current_user.admin?
  end

  def category_params
    params.require(:category).permit(:name)
  end

end
