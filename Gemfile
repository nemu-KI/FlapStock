# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.2.3'

# --- Rails本体・必須 ---
gem 'bootsnap', require: false    # 起動高速化
gem 'pg', '~> 1.1'                # PostgreSQL用
gem 'puma', '>= 5.0'              # Webサーバ
gem 'rails', '~> 7.1.2'

# --- フロントエンド・UI ---
gem 'importmap-rails'             # JS管理
gem 'sprockets-rails'             # アセット管理
gem 'stimulus-rails'              # Stimulus（JSフレームワーク）
gem 'tailwindcss-rails'           # TailwindCSS（CSSフレームワーク）
gem 'turbo-rails'                 # Turbo（ページ遷移高速化）

# --- ビュー・API ---
gem 'jbuilder' # JSONレスポンス生成

# --- 認証・権限管理 ---
gem 'devise' # 認証（ログイン機能）
gem 'devise-i18n' # Devise日本語化
gem 'pundit' # 権限管理

# --- メール配信 ---
gem 'sendgrid-ruby' # SendGrid Web API

# --- 検索・ソート ---
gem 'kaminari', '~> 1.2'          # ページネーション機能
gem 'ransack', '~> 4.1'           # 検索・ソート機能

# --- グラフ・可視化 ---
gem 'chartkick'                   # グラフ描画ライブラリ
gem 'groupdate'                   # 日付グループ化・集計

# --- OS依存 ---
gem 'tzinfo-data', platforms: %i[windows jruby] # Windows用タイムゾーン

# --- 開発・テスト共通 ---
group :development, :test do
  gem 'debug', platforms: %i[mri windows] # デバッグ
  gem 'dotenv-rails'                              # 環境変数管理
  gem 'rubocop'                                   # コード品質チェック
  gem 'rubocop-rails'                             # Rails用Rubocopルール
  gem 'rubocop-rspec'                             # RSpec用Rubocopルール
end

# --- 開発専用 ---
group :development do
  gem 'letter_opener_web', '~> 2.0' # メール確認用
  gem 'web-console' # ブラウザでのデバッグ
  # gem "rack-mini-profiler"                      # パフォーマンス計測
  # gem "spring"                                  # コマンド高速化
end

# --- テスト専用 ---
group :test do
  gem 'capybara'                                # E2Eテスト
  gem 'database_cleaner-active_record'          # テストDBクリーンアップ
  gem 'factory_bot_rails'                       # テストデータファクトリ
  gem 'faker'                                   # ダミーデータ生成
  gem 'rails-controller-testing'                # コントローラーテスト用
  gem 'rspec-rails'                             # RSpecテストフレームワーク
  gem 'selenium-webdriver'                      # ブラウザ自動操作
  gem 'shoulda-matchers'                        # テストマッチャー
end

# --- 画像アップロード（必要なら有効化） ---
# gem "image_processing", "~> 1.2"
