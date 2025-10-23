# frozen_string_literal: true

# ゲストデータ管理サービス
class GuestDataService
  def self.find_guest_company
    guest_company = Company.find_by(name: 'ゲスト企業', email: 'guest@example.com')
    unless guest_company
      puts 'エラー: ゲスト企業が見つかりません。先に \'rails guest:setup\' を実行してください。'
      exit 1
    end
    guest_company
  end

  def self.cleanup_existing_sample_data(guest_company)
    puts '既存のサンプルデータを削除中...'
    guest_company.stock_movements.destroy_all
    guest_company.items.destroy_all
    guest_company.categories.destroy_all
    guest_company.locations.destroy_all
    guest_company.suppliers.destroy_all
  end

  def self.create_categories(guest_company)
    puts 'カテゴリを作成中...'
    categories_data = [
      { name: 'IT機器', description: 'コンピューター関連機器' },
      { name: '文房具', description: 'オフィス文房具' },
      { name: '家具', description: 'オフィス家具' }
    ]

    created_categories = categories_data.map do |cat_data|
      guest_company.categories.create!(cat_data)
    end
    puts "カテゴリを#{created_categories.count}個作成しました"
    created_categories
  end

  def self.create_locations(guest_company)
    puts '場所を作成中...'
    locations_data = [
      { name: '1階倉庫', description: '1階の倉庫エリア' },
      { name: '2階倉庫', description: '2階の倉庫エリア' },
      { name: 'オフィス', description: 'オフィスエリア' }
    ]

    created_locations = locations_data.map do |loc_data|
      guest_company.locations.create!(loc_data)
    end
    puts "場所を#{created_locations.count}個作成しました"
    created_locations
  end

  def self.create_suppliers(guest_company)
    puts '仕入先を作成中...'
    suppliers_data = [
      { name: 'ABC商事', email: 'abc@guest-demo.local', phone: '03-1111-1111' },
      { name: 'XYZ株式会社', email: 'xyz@guest-demo.local', phone: '03-2222-2222' },
      { name: 'サンプル商店', email: 'sample@guest-demo.local', phone: '03-3333-3333' }
    ]

    created_suppliers = suppliers_data.map do |sup_data|
      guest_company.suppliers.create!(sup_data)
    end
    puts "仕入先を#{created_suppliers.count}個作成しました"
    created_suppliers
  end

  def self.create_items(guest_company, created_categories, created_locations, created_suppliers)
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

    items_data.map do |item_data|
      guest_company.items.create!(item_data)
    end
  end

  def self.create_stock_movements(guest_company, created_items)
    puts '在庫移動履歴を作成中...'
    guest_user = guest_company.users.find_by(email: 'guest@example.com')
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
    puts '在庫移動履歴を作成しました'
  end

  def self.display_sample_data_summary(guest_company)
    puts '=== サンプルデータの作成完了 ==='
    puts '作成されたデータ:'
    puts "  カテゴリ: #{guest_company.categories.count}件"
    puts "  場所: #{guest_company.locations.count}件"
    puts "  仕入先: #{guest_company.suppliers.count}件"
    puts "  物品: #{guest_company.items.count}件"
    puts "  在庫移動: #{guest_company.stock_movements.count}件"
  end

  def self.destroy_related_data(guest_company)
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
  end

  def self.destroy_company_and_users(guest_company)
    puts 'ユーザーを削除中...'
    guest_company.users.destroy_all
    puts '企業を削除中...'
    guest_company.destroy!
  end
end
