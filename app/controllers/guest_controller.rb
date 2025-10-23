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
end
