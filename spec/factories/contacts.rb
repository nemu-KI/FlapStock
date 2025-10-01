FactoryBot.define do
  factory :contact do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    category { %w[bug feature other].sample }
    priority { %w[high medium low].sample }
    status { 'pending' }
    subject { Faker::Lorem.sentence }
    message { Faker::Lorem.paragraph }
    user
    company { user.company }
  end
end
