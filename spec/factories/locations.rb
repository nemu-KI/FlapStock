FactoryBot.define do
  factory :location do
    name { Faker::Address.street_name }
    description { Faker::Lorem.sentence }
    association :company
  end
end
