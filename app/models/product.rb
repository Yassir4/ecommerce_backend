class Product < ApplicationRecord
    belongs_to :user
    validates_presence_of :user
end