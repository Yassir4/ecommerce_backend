class Product < ApplicationRecord
    belongs_to :user
    validates :user, :name, :price, presence: true
end
