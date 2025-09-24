# frozen_string_literal: true

# リクエストテスト用のヘルパーメソッド
module RequestHelpers
  def sign_in(user)
    # Deviseのテストヘルパーを使用
    login_as(user, scope: :user)
  end

  def sign_out
    logout(:user)
  end

  def json_response
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include RequestHelpers, type: :request
  # Deviseのテストヘルパーを追加
  config.include Devise::Test::IntegrationHelpers, type: :request
end
