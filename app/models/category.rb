class Category < ApplicationRecord
    validates :name, uniqueness: true, presence: true
    has_many :products
end
