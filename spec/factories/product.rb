FactoryBot.define do
    factory :product do
        name { Faker::Commerce.product_name }
        user {FactoryBot.create(:user)}
        price { Faker::Commerce.price(range: 1..100) }
        description { Faker::Lorem.sentence(word_count: 12) }
        category {FactoryBot.create(:category)}
        quantity { 10 }
    end
end