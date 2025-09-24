# frozen_string_literal: true

FactoryBot.define do
  factory :stock_movement do
    movement_category { %i[inbound outbound adjustment].sample }
    quantity { Faker::Number.between(from: 1, to: 50) }
    reason { Faker::Lorem.sentence(word_count: 3) }
    note { Faker::Lorem.sentence }
    association :company
    association :user
    association :item
  end
end
