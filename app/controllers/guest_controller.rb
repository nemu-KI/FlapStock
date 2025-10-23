# frozen_string_literal: true

# ゲストログイン機能
class GuestController < ApplicationController
  before_action :redirect_if_authenticated, only: [:login]
  before_action :authenticate_user!, only: [:logout]

  def login
    # ゲストログイン画面を表示
  end

  def create_session
    # ゲストユーザーを取得または作成
    guest_user = User.find_by(email: 'guest@example.com')

    unless guest_user
      # ゲストユーザーが存在しない場合は自動作成
      guest_user = create_guest_user

      unless guest_user
        redirect_to guest_login_path, alert: 'ゲストユーザーの作成に失敗しました。管理者にお問い合わせください。'
        return
      end
    end

    # ゲストユーザーでログイン
    sign_in(guest_user)

    # ゲストモードのセッション情報を設定
    session[:guest_mode] = true
    session[:guest_session_start] = Time.current.to_s

    # サンプルデータが存在しない場合は作成
    ensure_sample_data_exists(guest_user.company)

    redirect_to root_path, notice: 'お試しモードでログインしました。データは一時的なものです。'
  rescue StandardError => e
    Rails.logger.error "Guest login failed: #{e.message}"
    redirect_to guest_login_path, alert: 'ゲストログインに失敗しました。'
  end

  def logout
    # ゲストモードのセッション情報をクリア
    session[:guest_mode] = false

    # ログアウト
    sign_out(current_user)

    redirect_to root_path, notice: 'お試しモードからログアウトしました。'
  end

  private

  def redirect_if_authenticated
    redirect_to root_path if user_signed_in?
  end

  def create_guest_user
    # ゲスト企業を取得または作成
    guest_company = Company.find_or_create_by(name: 'ゲスト企業', email: 'guest@example.com') do |company|
      company.phone = '03-1234-5678'
      company.active = true
      company.timezone = 'Tokyo'
      company.guest = true
    end

    # ゲストユーザーを作成
    User.create!(
      name: 'ゲストユーザー',
      email: 'guest@example.com',
      password: 'guest123',
      password_confirmation: 'guest123',
      role: 'manager',
      company: guest_company,
      per_page: 20
    )
  rescue StandardError => e
    Rails.logger.error "Failed to create guest user: #{e.message}"
    nil
  end

  def ensure_sample_data_exists(guest_company)
    return if guest_company.items.any?

    Rails.logger.info "Creating sample data for guest company: #{guest_company.name}"
    create_sample_data(guest_company)
  end

  def create_sample_data(guest_company)
    # カテゴリを作成
    categories = [
      { name: 'IT機器', description: 'コンピューター関連機器' },
      { name: '文房具', description: 'オフィス文房具' },
      { name: '家具', description: 'オフィス家具' }
    ].map { |cat_data| guest_company.categories.create!(cat_data) }

    # 場所を作成
    locations = [
      { name: '1階倉庫', description: '1階の倉庫エリア' },
      { name: '2階倉庫', description: '2階の倉庫エリア' },
      { name: 'オフィス', description: 'オフィスエリア' }
    ].map { |loc_data| guest_company.locations.create!(loc_data) }

    # 仕入先を作成
    suppliers = [
      { name: 'ABC商事', email: 'abc@guest-demo.local', phone: '03-1111-1111' },
      { name: 'XYZ株式会社', email: 'xyz@guest-demo.local', phone: '03-2222-2222' },
      { name: 'サンプル商店', email: 'sample@guest-demo.local', phone: '03-3333-3333' }
    ].map { |sup_data| guest_company.suppliers.create!(sup_data) }

    # 物品を作成
    items_data = [
      { name: 'ノートパソコン', description: 'ビジネス用ノートパソコン', category: categories[0], location: locations[0],
        supplier: suppliers[0], stock_quantity: 5, min_stock: 2, unit: '台' },
      { name: 'ボールペン', description: '黒色ボールペン', category: categories[1], location: locations[1],
        supplier: suppliers[1], stock_quantity: 50, min_stock: 10, unit: '本' },
      { name: 'デスク', description: 'オフィス用デスク', category: categories[2], location: locations[2],
        supplier: suppliers[2], stock_quantity: 3, min_stock: 1, unit: '台' },
      { name: 'マウス', description: 'USBマウス', category: categories[0], location: locations[0],
        supplier: suppliers[0], stock_quantity: 8, min_stock: 3, unit: '個' },
      { name: 'コピー用紙', description: 'A4コピー用紙', category: categories[1], location: locations[1],
        supplier: suppliers[1], stock_quantity: 20, min_stock: 5, unit: '束' }
    ]

    items = items_data.map { |item_data| guest_company.items.create!(item_data) }

    # 在庫移動履歴を作成
    guest_user = guest_company.users.find_by(email: 'guest@example.com')
    items.each_with_index do |item, index|
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

    Rails.logger.info "Sample data created: #{guest_company.items.count} items, #{guest_company.stock_movements.count} movements"
  rescue StandardError => e
    Rails.logger.error "Failed to create sample data: #{e.message}"
  end
end
