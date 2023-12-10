require 'faker'

10.times do 
    user  = User.create(email: Faker::Internet.email, name: Faker::Internet.username, password: '123456')
    10.times do
        Product.create(name: Faker::Commerce.product_name, price: Faker::Commerce.price(range: 1..100),
         user: user, category_id: rand(2..8), description: Faker::Lorem.sentence(word_count: 12))
    end
end