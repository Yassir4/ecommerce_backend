class Product < ApplicationRecord
    belongs_to :user
    belongs_to :category

    validates :user, :name, :price, :category , presence: true
end
