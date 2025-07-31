# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# 環境別のseedファイルを読み込み
if Rails.env.development?
  load(Rails.root.join('db', 'seeds', 'development.rb'))
  load(Rails.root.join('db', 'seeds', 'items.rb'))
elsif Rails.env.test?
  # テスト環境用のseedデータ（必要に応じて追加）
  puts "🧪 テスト環境用seedデータを作成中..."
end
