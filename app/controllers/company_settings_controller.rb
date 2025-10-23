# frozen_string_literal: true

# CompanySettingsController
class CompanySettingsController < ApplicationController
  include Devise::Controllers::SignInOut

  before_action :authenticate_user!
  before_action :set_company
  before_action :authorize_company_settings
  before_action :check_guest_restrictions

  def index
    # 統合設定画面の表示
  end

  def show
    # 設定画面の表示
  end

  def edit
    # 設定編集画面の表示
  end

  def update
    if @company.update(company_params)
      redirect_to settings_path, notice: '会社情報を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # 表示設定の更新（ユーザー単位）
  def update_display
    authorize current_user, :update_display?

    if current_user.update(display_params)
      redirect_to settings_path, notice: '表示設定を更新しました。'
    else
      redirect_to settings_path, alert: current_user.errors.full_messages.join(', ')
    end
  end

  # アラート設定の更新（会社単位）
  def update_alerts
    log_alert_update_attempt

    if @company.update(alert_params)
      log_alert_update_success
      redirect_to settings_path, notice: 'アラート設定を更新しました。'
    else
      log_alert_update_failure
      redirect_to settings_path, alert: @company.errors.full_messages.join(', ')
    end
  end

  # ユーザー設定の更新（ユーザー単位）
  def update_user
    authorize current_user, :update_display?

    if user_params[:current_password].present?
      handle_password_change
    else
      handle_profile_update
    end
  end

  # ユーザー権限の更新（管理者のみ）
  def update_user_role
    authorize @company, :manage_users?

    user = @company.users.find(params[:user_id])
    new_role = params[:role]

    if user.update(role: new_role)
      render json: { success: true, message: "#{user.name}の権限を#{role_display_name(new_role)}に変更しました。" }
    else
      render json: { success: false, message: user.errors.full_messages.join(', ') }
    end
  end

  # パスワードリセット（管理者のみ）
  def reset_user_password
    authorize @company, :manage_users?

    user = @company.users.find(params[:user_id])
    new_password = SecureRandom.hex(8) # 8文字のランダムパスワード

    if user.update(password: new_password, password_confirmation: new_password)
      # パスワードリセットメールを送信
      UserMailer.password_reset(user, new_password).deliver_now
      render json: { success: true, message: "#{user.name}のパスワードをリセットしました。新しいパスワードをメールで送信しました。" }
    else
      render json: { success: false, message: user.errors.full_messages.join(', ') }
    end
  end

  # ユーザー削除（管理者のみ）
  def delete_user
    authorize @company, :manage_users?

    user = @company.users.find(params[:user_id])

    # 自分自身は削除できない
    if user == current_user
      render json: { success: false, message: '自分自身を削除することはできません。' }
      return
    end

    if user.destroy
      render json: { success: true, message: "#{user.name}を削除しました。" }
    else
      render json: { success: false, message: user.errors.full_messages.join(', ') }
    end
  end

  private

  def set_company
    @company = current_user.company
  end

  def authorize_company_settings
    authorize @company, :update?
  end

  def company_params
    params.require(:company).permit(:name, :email, :phone, :address, :timezone)
  end

  def display_params
    params.require(:user).permit(:per_page)
  end

  def alert_params
    params.require(:company).permit(:email_notifications_enabled, :notification_frequency, :notification_time,
                                    notification_recipients_list: [])
  end

  def user_params
    params.require(:user).permit(:name, :current_password, :password, :password_confirmation)
  end

  def role_display_name(role)
    case role
    when 'admin' then '管理者'
    when 'manager' then 'マネージャー'
    when 'staff' then 'スタッフ'
    else role
    end
  end

  def log_alert_update_attempt
    Rails.logger.info "Alert params: #{alert_params.inspect}"
    Rails.logger.info "Company before update: #{@company.attributes.slice(
      'email_notifications_enabled', 'notification_frequency', 'notification_time', 'notification_recipients'
    )}"
  end

  def log_alert_update_success
    Rails.logger.info "Company after update: #{@company.attributes.slice(
      'email_notifications_enabled', 'notification_frequency', 'notification_time', 'notification_recipients'
    )}"
  end

  def log_alert_update_failure
    Rails.logger.error "Update failed: #{@company.errors.full_messages}"
  end

  def handle_password_change
    if current_user.update_with_password(user_params)
      # パスワード変更後は自動的にログアウトされるため、再ログインする
      sign_in(current_user, bypass: true)
      redirect_to settings_path, notice: 'パスワードを変更しました。'
    else
      redirect_to settings_path, alert: current_user.errors.full_messages.join(', ')
    end
  end

  def handle_profile_update
    if current_user.update(user_params.except(:current_password, :password, :password_confirmation))
      redirect_to settings_path, notice: 'プロフィールを更新しました。'
    else
      redirect_to settings_path, alert: current_user.errors.full_messages.join(', ')
    end
  end

  # ゲストユーザーの制限チェック
  def check_guest_restrictions
    return unless session[:guest_mode]

    redirect_to root_path, alert: 'お試しモードでは設定機能はご利用いただけません。正式登録後にご利用ください。'
  end
end
