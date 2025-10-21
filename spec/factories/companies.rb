# frozen_string_literal: true

FactoryBot.define do
  factory :company do
    name { Faker::Company.name }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
    timezone { 'Tokyo' }
    active { true }
  end
end
