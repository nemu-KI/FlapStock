# frozen_string_literal: true

# Database Cleanerの設定
require 'database_cleaner/active_record'

RSpec.configure do |config|
  # テスト環境のみでDatabase Cleanerを有効化
  if Rails.env.test?
    config.before(:suite) do
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.clean_with(:truncation)
    end

    config.around(:each) do |example|
      DatabaseCleaner.cleaning do
        example.run
      end
    end
  end
end
