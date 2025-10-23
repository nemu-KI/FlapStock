# frozen_string_literal: true

namespace :guest do
  desc 'ゲスト企業とユーザーを作成'
  task setup: :environment do
    puts '=== ゲスト企業とユーザーの作成を開始 ==='

    # 既存のゲスト企業を削除（存在する場合）
    existing_company = Company.find_by(name: 'ゲスト企業', email: 'guest@example.com')
    if existing_company
      puts '既存のゲスト企業を削除中...'
      existing_company.destroy!
    end

    # ゲスト企業を作成
    puts 'ゲスト企業を作成中...'
    guest_company = Company.create!(
      name: 'ゲスト企業',
      email: 'guest@example.com',
      phone: '03-1234-5678',
      address: '東京都渋谷区',
      timezone: 'Tokyo',
      active: true,
      email_notifications_enabled: false
    )
    puts "ゲスト企業を作成しました: #{guest_company.id}"

    # 既存のゲストユーザーを削除（存在する場合）
    existing_user = User.find_by(email: 'guest@example.com')
    if existing_user
      puts '既存のゲストユーザーを削除中...'
      existing_user.destroy!
    end

    # ゲストユーザーを作成
    puts 'ゲストユーザーを作成中...'
    guest_user = User.new(
      name: 'ゲストユーザー',
      email: 'guest@example.com',
      password: 'guest123',
      password_confirmation: 'guest123',
      role: 'manager',
      company: guest_company,
      per_page: 20
    )

    # コールバックを回避して直接保存
    guest_user.save!(validate: false)

    # 権限を確実にmanagerに設定
    guest_user.update_column(:role, 'manager')
    puts "ゲストユーザーを作成しました: #{guest_user.id}"

    puts '=== ゲスト企業とユーザーの作成完了 ==='
    puts 'ログイン情報:'
    puts '  メールアドレス: guest@example.com'
    puts '  パスワード: guest123'
  end

  desc 'ゲスト企業のサンプルデータを作成'
  task sample_data: :environment do
    puts '=== ゲスト企業のサンプルデータを作成中 ==='

    guest_company = Company.find_by(name: 'ゲスト企業', email: 'guest@example.com')
    unless guest_company
      puts "エラー: ゲスト企業が見つかりません。先に 'rails guest:setup' を実行してください。"
      exit 1
    end

    # 既存のサンプルデータを削除
    puts '既存のサンプルデータを削除中...'
    guest_company.items.destroy_all
    guest_company.categories.destroy_all
    guest_company.locations.destroy_all
    guest_company.suppliers.destroy_all
    guest_company.stock_movements.destroy_all

    # カテゴリを作成
    puts 'カテゴリを作成中...'
    categories = [
      { name: 'IT機器', description: 'コンピューター関連機器' },
      { name: '文具', description: 'オフィス文具' },
      { name: '家具', description: 'オフィス家具' }
    ]

    created_categories = categories.map do |cat_data|
      guest_company.categories.create!(cat_data)
    end
    puts "カテゴリを#{created_categories.count}個作成しました"

    # 場所を作成
    puts '場所を作成中...'
    locations = [
      { name: '1階倉庫', description: '1階の倉庫エリア' },
      { name: '2階倉庫', description: '2階の倉庫エリア' },
      { name: 'オフィス', description: 'オフィスエリア' }
    ]

    created_locations = locations.map do |loc_data|
      guest_company.locations.create!(loc_data)
    end
    puts "場所を#{created_locations.count}個作成しました"

    # 仕入先を作成（安全なメールアドレスを使用）
    puts '仕入先を作成中...'
    suppliers = [
      { name: 'ABC商事', email: 'abc@guest-demo.local', phone: '03-1111-1111' },
      { name: 'XYZ株式会社', email: 'xyz@guest-demo.local', phone: '03-2222-2222' },
      { name: 'サンプル商店', email: 'sample@guest-demo.local', phone: '03-3333-3333' }
    ]

    created_suppliers = suppliers.map do |sup_data|
      guest_company.suppliers.create!(sup_data)
    end
    puts "仕入先を#{created_suppliers.count}個作成しました"

    # 物品を作成
    puts '物品を作成中...'
    items_data = [
      { name: 'ノートパソコン', description: 'ビジネス用ノートパソコン', category: created_categories[0], location: created_locations[0],
        supplier: created_suppliers[0], stock_quantity: 5, min_stock: 2, unit: '台' },
      { name: 'ボールペン', description: '黒色ボールペン', category: created_categories[1], location: created_locations[1],
        supplier: created_suppliers[1], stock_quantity: 50, min_stock: 10, unit: '本' },
      { name: 'デスク', description: 'オフィス用デスク', category: created_categories[2], location: created_locations[2],
        supplier: created_suppliers[2], stock_quantity: 3, min_stock: 1, unit: '台' },
      { name: 'マウス', description: 'USBマウス', category: created_categories[0], location: created_locations[0],
        supplier: created_suppliers[0], stock_quantity: 8, min_stock: 3, unit: '個' },
      { name: 'コピー用紙', description: 'A4コピー用紙', category: created_categories[1], location: created_locations[1],
        supplier: created_suppliers[1], stock_quantity: 20, min_stock: 5, unit: '束' }
    ]

    created_items = items_data.map do |item_data|
      guest_company.items.create!(item_data)
    end
    puts "物品を#{created_items.count}個作成しました"

    # 在庫移動履歴を作成
    puts '在庫移動履歴を作成中...'
    guest_user = guest_company.users.find_by(email: 'guest@example.com')

    # 入庫履歴
    created_items.each_with_index do |item, index|
      quantity = [5, 10, 3, 8, 15][index] || 5
      guest_company.stock_movements.create!(
        item: item,
        user: guest_user,
        movement_category: 'inbound',
        quantity: quantity,
        reason: '初期在庫',
        note: 'ゲスト用サンプルデータ'
      )
    end

    # 出庫履歴（一部の物品）
    created_items.first(3).each do |item|
      guest_company.stock_movements.create!(
        item: item,
        user: guest_user,
        movement_category: 'outbound',
        quantity: 2,
        reason: '使用',
        note: 'ゲスト用サンプルデータ'
      )
    end

    puts '在庫移動履歴を作成しました'

    puts '=== サンプルデータの作成完了 ==='
    puts '作成されたデータ:'
    puts "  カテゴリ: #{guest_company.categories.count}個"
    puts "  場所: #{guest_company.locations.count}個"
    puts "  仕入先: #{guest_company.suppliers.count}個"
    puts "  物品: #{guest_company.items.count}個"
    puts "  在庫移動: #{guest_company.stock_movements.count}件"
  end

  desc 'ゲスト企業のデータをリセット'
  task reset: :environment do
    puts '=== ゲスト企業のデータをリセット中 ==='

    guest_company = Company.find_by(name: 'ゲスト企業', email: 'guest@example.com')
    if guest_company
      puts 'ゲスト企業のデータを削除中...'

      # 関連データを順番に削除
      puts '在庫移動履歴を削除中...'
      guest_company.stock_movements.destroy_all

      puts '物品を削除中...'
      guest_company.items.destroy_all

      puts 'カテゴリを削除中...'
      guest_company.categories.destroy_all

      puts '場所を削除中...'
      guest_company.locations.destroy_all

      puts '仕入先を削除中...'
      guest_company.suppliers.destroy_all

      puts 'ユーザーを削除中...'
      guest_company.users.destroy_all

      puts '企業を削除中...'
      guest_company.destroy!

      puts 'ゲスト企業のデータを削除しました'
    else
      puts 'ゲスト企業が見つかりません'
    end

    puts '=== リセット完了 ==='
  end
end
