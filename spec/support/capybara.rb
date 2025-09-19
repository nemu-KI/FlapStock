# Capybaraの設定
require 'capybara/rails'
require 'capybara/rspec'

# システムテスト用の設定
Capybara.configure do |config|
  # まずはRack::Testドライバーを使用（JavaScript不要なテスト用）
  config.default_driver = :rack_test
  config.javascript_driver = :selenium_chrome_headless
  config.default_max_wait_time = 5
  config.server = :puma, { Silent: true }
  config.app_host = 'http://www.example.com:3000'
end

# Rack::Testドライバーの設定（JavaScript不要なテスト用）
Capybara.register_driver :rack_test do |app|
  Capybara::RackTest::Driver.new(app)
end

# Chromeのオプション設定（JavaScriptが必要なテスト用）
Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')
  options.add_argument('--disable-web-security')
  options.add_argument('--disable-features=VizDisplayCompositor')
  options.add_argument('--window-size=1280,720')
  options.add_argument('--remote-debugging-port=9222')

  # ChromeDriverの自動ダウンロードを有効化
  service = Selenium::WebDriver::Service.chrome
  service.port = 9515

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options,
    service: service
  )
end
