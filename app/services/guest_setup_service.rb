# frozen_string_literal: true

# ゲストセットアップサービス
class GuestSetupService
  def self.setup_guest_company_and_user
    puts '=== ゲスト企業とユーザーの作成を開始 ==='

    cleanup_existing_guest_data
    guest_company = create_guest_company
    create_guest_user(guest_company)

    display_login_info
  end

  def self.create_sample_data
    puts '=== ゲスト企業のサンプルデータを作成中 ==='

    guest_company = GuestDataService.find_guest_company
    GuestDataService.cleanup_existing_sample_data(guest_company)

    created_categories = GuestDataService.create_categories(guest_company)
    created_locations = GuestDataService.create_locations(guest_company)
    created_suppliers = GuestDataService.create_suppliers(guest_company)
    created_items = GuestDataService.create_items(guest_company, created_categories, created_locations,
                                                  created_suppliers)
    GuestDataService.create_stock_movements(guest_company, created_items)

    GuestDataService.display_sample_data_summary(guest_company)
  end

  def self.reset_guest_data
    puts '=== ゲスト企業のデータをリセット中 ==='

    guest_company = Company.find_by(name: 'ゲスト企業', email: 'guest@example.com')
    if guest_company
      destroy_guest_company_data(guest_company)
    else
      puts 'ゲスト企業が見つかりません'
    end

    puts '=== リセット完了 ==='
  end

  private_class_method def self.cleanup_existing_guest_data
    existing_company = Company.find_by(name: 'ゲスト企業', email: 'guest@example.com')
    if existing_company
      puts '既存のゲスト企業の関連データを削除中...'
      # 外部キー制約を考慮した削除順序
      existing_company.stock_movements.delete_all
      # order_itemsを先に削除
      existing_company.items.joins(:order_items).distinct.each do |item|
        item.order_items.delete_all
      end
      existing_company.items.delete_all
      existing_company.categories.delete_all
      existing_company.locations.delete_all
      existing_company.suppliers.delete_all
      existing_company.users.delete_all
      existing_company.delete
    end

    existing_user = User.find_by(email: 'guest@example.com')
    return unless existing_user

    puts '既存のゲストユーザーを削除中...'
    existing_user.delete
  end

  private_class_method def self.create_guest_company
    puts 'ゲスト企業を作成中...'
    Company.create!(
      name: 'ゲスト企業',
      email: 'guest@example.com',
      phone: '03-1234-5678',
      active: true,
      timezone: 'Tokyo',
      guest: true
    )
  end

  private_class_method def self.create_guest_user(guest_company)
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

    guest_user.save!(validate: false)
    guest_user.update_column(:role, 'manager')
  end

  private_class_method def self.display_login_info
    puts '=== ゲスト企業とユーザーの作成完了 ==='
    puts 'ログイン情報:'
    puts '  メールアドレス: guest@example.com'
    puts '  パスワード: guest123'
  end

  private_class_method def self.destroy_guest_company_data(guest_company)
    puts 'ゲスト企業のデータを削除中...'
    GuestDataService.destroy_related_data(guest_company)
    GuestDataService.destroy_company_and_users(guest_company)
    puts 'ゲスト企業のデータを削除しました'
  end
end
