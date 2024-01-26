FactoryBot.define do
    factory :category do
        sequence :name do |n|
            puts "baby#{n}toys" 
            "baby#{n}toys" 
        end
    end
end