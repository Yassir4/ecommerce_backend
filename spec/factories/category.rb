FactoryBot.define do
    factory :category do
        sequence :name do |n|
            "baby#{n}toys"
        end
    end
end