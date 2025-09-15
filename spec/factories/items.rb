FactoryBot.define do
  factory :item do
    name { Faker::Commerce.product_name }
    sku { Faker::Alphanumeric.alphanumeric(number: 10) }
    stock_quantity { Faker::Number.between(from: 0, to: 100) }
    unit { "個" }
    description { Faker::Lorem.sentence }
    min_stock { Faker::Number.between(from: 1, to: 10) }
    max_stock { Faker::Number.between(from: 50, to: 200) }
    image_url { Faker::Internet.url }
    association :company
    association :category
    association :location
    association :supplier
  end
end
