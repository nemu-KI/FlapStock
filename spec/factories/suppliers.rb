# frozen_string_literal: true

FactoryBot.define do
  factory :supplier do
    name { Faker::Company.name }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
    address { Faker::Address.full_address }
    contact_person { Faker::Name.name }
    note { Faker::Lorem.sentence }
    association :company
  end
end
