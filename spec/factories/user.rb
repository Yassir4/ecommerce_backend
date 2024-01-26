FactoryBot.define do
    factory :user do
        email {Faker::Internet.email}
        name {Faker::Internet.username}
        password {'password'}
    end
end