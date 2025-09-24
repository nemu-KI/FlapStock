# frozen_string_literal: true

# FactoryBotの設定
require 'factory_bot_rails'
require 'faker'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
