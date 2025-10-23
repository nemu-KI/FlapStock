# frozen_string_literal: true

# ゲストログイン機能
class GuestController < ApplicationController
  before_action :redirect_if_authenticated, only: [:login]
  before_action :authenticate_user!, only: [:logout]

  def login
    # ゲストログイン画面を表示
  end

  def create_session
    begin
      # ゲストユーザーを取得
      guest_user = User.find_by(email: 'guest@example.com')

      unless guest_user
        redirect_to guest_login_path, alert: 'ゲストユーザーが見つかりません。管理者にお問い合わせください。'
        return
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
end
