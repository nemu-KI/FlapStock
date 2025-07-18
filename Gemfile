source "https://rubygems.org"

ruby "3.2.3"

gem "rails", "~> 7.1.2"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "sprockets-rails"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "bootsnap", require: false

# Windows用
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Active Storage variants（画像アップロードを使う場合のみ）
# gem "image_processing", "~> 1.2"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
  gem "dotenv-rails"
end

group :development do
  gem "web-console"
  # gem "rack-mini-profiler"
  # gem "spring"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
